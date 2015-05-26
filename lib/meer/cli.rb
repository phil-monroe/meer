require 'meer/datameer'
require 'yaml'

module Meer
  class CLI < ::Thor
    desc "login", "logs into datameer for quick access"
    def login
      user     = ask("username:", default: ENV['USER'])
      password = ask("password:", :echo => false)
      puts
      
      client(user, password).login
    end
    
    desc "workbooks", "lists all workbooks"
    def workbooks 
      client.workbooks.sort_by { |w| w['path'] }.each do |workbook|
        puts " - [#{workbook['id']}] #{workbook['path']}"
      end
    end
    
    desc "sheets", "lists all sheets in a workbook"
    def sheets(workbook_id)
      client.workbook(workbook_id)['sheets'].each do |sheet|
        puts " - #{sheet['name']}"
      end
    end
    
    desc "csv", "outputs the CSV for a given workbook"
    def csv(workbook, sheet)
      puts client.workbook_data(workbook, sheet)
    end
    
    desc "table", "outputs a nicely formatted table for a given workbook"
    def table(workbook, sheet)
      data = client.workbook_data(workbook, sheet)
      rows = CSV.parse(data, :headers => true).to_a
      puts Terminal::Table.new headings: rows[0], rows: rows[1..-1]
    end

    
    private
        
    def client user=nil, password=nil
      @client = Datameer.new ENV['DATAMEER_URL'], user, password
    end
  end
end