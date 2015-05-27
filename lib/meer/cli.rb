require 'meer/datameer'
require 'time'

module Meer
  class CLI < ::Thor
    desc "login", "Logs into datameer for quick access"
    def login
      user     = ask("username:", default: ENV['USER'])
      password = ask("password:", :echo => false)
      puts
      
      client(user, password).login
    end
    
    desc "workbooks", "Lists all workbooks"
    def workbooks 
      client.workbooks.sort_by { |w| w['path'] }.each do |workbook|
        puts " - [#{workbook['id']}] #{workbook['path']}"
      end
    end
    
    desc "sheets [WORKBOOK-ID]", "Lists all sheets in a workbook"
    def sheets(workbook_id)
      client.workbook(workbook_id)['sheets'].each do |sheet|
        puts " - #{sheet['name']}"
      end
    end
    
    desc "csv [WORKBOOK-ID] [SHEET_NAME]", "Outputs the CSV for a given workbook"
    def csv(workbook, sheet)
      puts client.workbook_data(workbook, sheet)
    end
    
    desc "table [WORKBOOK-ID] [SHEET_NAME]", "Outputs a nicely formatted table for a given workbook"
    option :sort,   type: :string
    option :filter, type: :string
    def table(workbook, sheet)
      data = client.workbook_data(workbook, sheet)
      rows = CSV.parse(data, :headers => true).to_a
      headers = rows.slice!(0)
      schema = parse_schema(headers, rows.first)
      
      filter!(schema, rows, options[:filter]) if options[:filter]
      sort!(schema, rows, options[:sort]) if options[:sort]
      
      puts Terminal::Table.new(headings: headers, rows: rows)
    end

    
    private
        
    def client user=nil, password=nil
      @client = Datameer.new ENV['DATAMEER_URL'], user, password
    end
    
    def parse_schema(headers, row)
      schema = Hash.new
      headers.each_with_index do |col_name, idx|
        
        type    = :number if Float(row[idx]) rescue false
        type  ||= :time   if row[idx] =~ /\A\w+ \d{1,2}, \d{4} \d{1,2}:\d{1,2}:\d{1,2} (AM|PM)\z/
        type  ||= :string
        
        schema[col_name] = OpenStruct.new type: type, index: idx
      end
      
      schema
    end
    
    def filter! schema, rows, filter_str
      cols = filter_str.split(?,).map do |name| 
        name, q = name.split('=')
        OpenStruct.new(col: schema[name], query: q)
      end

      rows.select! do |row|
        cols.map{|c| row[c.col.index].to_s =~ /#{c.query}/ }.all?
      end
    end
    
    
    def sort! schema, rows, sort_str
      cols = sort_str.split(',').map do |name| 
        reverse = name[-1] == '-'
        name    = name[0..-2] if reverse

        OpenStruct.new(col: schema[name], reverse: reverse)
      end
      
      rows.sort_by! do |row| 
        cols.map do |c| 
          val = row[c.col.index]
          val = val.to_f              if c.col.type == :number
          val = Time.parse(val)       if c.col.type == :time
          val = ReverseOrder.new(val) if c.reverse
          val
        end
      end
    end
    
    
    
    class ReverseOrder 
      attr_reader :obj
      def initialize obj
        @obj = obj
      end
  
      def <=>(other)
        -(@obj <=> other.obj)
      end
    end
  end
end

