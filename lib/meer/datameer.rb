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
        puts "Basic Auth"
        req.basic_auth self.user, self.password
      else
        req['Cookie'] = File.read('.session')
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

    
    def login
      resp = get('/browser')
      
      if resp.code.to_i == 200
        File.open('.session', 'w') { |f| f.puts resp['set-cookie'] }
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
  end
end