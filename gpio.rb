require 'rest_client'

class GPIO
  class <<self
    def port
      ENV['PORT'] || 2
    end

    def host
      ENV['PI_HOST'] || 'localhost'
    end

    def on
      resource("http://#{host}:8000/GPIO/#{port}/function/out").post({})
      resource("http://#{host}:8000/GPIO/#{port}/value/1").post({})
      sleep 3
    end

    def off
      resource("http://#{host}:8000/GPIO/#{port}/function/out").post({})
      resource("http://#{host}:8000/GPIO/#{port}/value/0").post({})
    end

    private
    def resource(url)
      RestClient::Resource.new(url, :user => 'webiopi', :password => 'raspberry')
    end
  end
end
