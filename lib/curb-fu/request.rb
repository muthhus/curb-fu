require 'rubygems'
require 'curb'

module CurbFu
  class Request
    class << self
      def timeout=(val)
        @timeout = val
      end
      
      def timeout
        @timeout.nil? ? 60 : @timeout
      end
      
      def build(params)
        curb = Curl::Easy.new(build_url(params))
        unless params.is_a?(String)
          curb.userpwd = "#{params[:username]}:#{params[:password]}" if params[:username]
          curb.headers = params[:headers] || {}
        end
        
        curb.timeout = @timeout
        
        curb
      end
      
      def build_url(params)
        if params.is_a? String
          return params
        else
          built_url = "http://#{params[:host]}"
          built_url += ":" + params[:port].to_s if params[:port]
          built_url += params[:path] if params[:path]
          
          return built_url
        end
      end
      
      def get(url)
        curb = self.build(url)
        curb.http_get
        CurbFu::Response::Base.create(curb)
      end
      
      def put(url, params)
        fields = create_fields(params)
        
        curb = self.build(url)
        curb.http_put(*fields)
        CurbFu::Response::Base.create(curb)
      end
      
      def post(url, params = {})
        fields = create_fields(params)
        
        curb = self.build(url)
        curb.headers["Expect:"] = ''
        curb.http_post(*fields)
        CurbFu::Response::Base.create(curb)
      end
      
      def post_file(url, params = {}, filez = {})
        fields = create_fields(params)
        fields += create_file_fields(filez)
        
        curb = self.build(url)
        curb.multipart_form_post = true
        curb.http_post(*fields)
        CurbFu::Response::Base.create(curb)
      end
      
      def delete(url)
        curb = self.build(url)
        curb.http_delete
        CurbFu::Response::Base.create(curb)
      end
      
      def create_fields(params)
        fields = []
        params.each do |name, value|
          value_string = value if value.is_a?(String)
          value_string = value.join(',') if value.is_a?(Array)
          value_string ||= value.to_s
          
          fields << Curl::PostField.content(name,value_string)
        end
        return fields
      end
      
      def create_file_fields(filez)
        fields = []
        filez.each do |name, path|
          fields << Curl::PostField.file(name, path)
        end
        fields
      end
    end
  end
end