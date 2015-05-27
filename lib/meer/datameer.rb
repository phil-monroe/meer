require 'fileutils'

module Meer
  class Datameer
    attr_reader :uri, :user, :password 
    def initialize url, user=nil, password=nil
      @uri, @user, @password = URI(url), user, password
      
      @http = Net::HTTP.new uri.host, uri.port
      @http.use_ssl = true if uri.port == 443
    end 
    
    
    def request req
      if [user, password].compact.size == 2
        req.basic_auth self.user, self.password
      else
        req['Cookie'] = Session.load
      end

      res = @http.request(req)
      if res.code == '200'
        res
      else
        puts "error fetching #{req.uri}"
        puts res.code
        puts res.to_hash
      end  
    end

    def get url
      req = Net::HTTP::Get.new(URI(uri.to_s + url))
      request(req)
    end
    
    def post url
      req = Net::HTTP::Post.new(URI(uri.to_s + url))
      request(req)      
    end

    
    def login
      resp = get('/browser')
      
      if resp.code.to_i == 200
        Session.set(resp['set-cookie'])
        puts "Logged In"
      else
        puts "Failed to log in"
      end      
    end
    
    
    def workbook_data wb_id, sheet
      res = get "/rest/data/workbook/#{wb_id}/#{sheet}/download"
      res.body
    end
    
    def workbook wb_id
      JSON.parse(get("/rest/workbook/#{wb_id}").body)
    end
    
    def workbooks
      JSON.parse(get("/rest/workbook").body)
    end
    
    def run_workbook wb_id
      JSON.parse post("/rest/job-execution?configuration=#{wb_id}").body
    end
    
    def running_jobs
      JSON.parse get("/rest/jobs/list-running").body
    end
    
    module Session
      SESSION_FILE = File.expand_path('~/.dmsession')
      
      def self.set(cookie)
        FileUtils.rm_f SESSION_FILE
        File.open(SESSION_FILE, 'w') { |f| f.puts cookie }
        File.chmod(0400, SESSION_FILE)
      end
      
      def self.load
        File.read(SESSION_FILE) if File.exist?(SESSION_FILE)
      end
    end
  end
end