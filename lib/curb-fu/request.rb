require 'rubygems'
require 'curb'

module CurbFu
  class Request
    class << self
      def build(params)
        if params.is_a? String
          built_url = params
        else
          built_url = 'http://'
          built_url += params[:host]
          built_url += ":" + params[:port].to_s if params[:port]
          built_url += params[:path] || ""
        end
        
        curb = Curl::Easy.new(built_url)
        unless params.is_a?(String)
          curb.userpwd = "#{params[:username]}:#{params[:password]}" if params[:username]
          curb.headers = params[:headers] || {}
        end
        curb
      end
      
      def get(url)
        curb = self.build(url)
        curb.http_get
        CurbFu::Response::Base.create(curb)
      end
      
      def put(url, params)
        fields = []
        params.each do |name, value|
          fields << Curl::PostField.content(name,value)
        end
        
        curb = self.build(url)
        curb.http_put(*fields)
        CurbFu::Response::Base.create(curb)
      end
      
      def post(url, params = {})
        fields = []
        params.each do |name, value|
          fields << Curl::PostField.content(name,value)
        end
        
        curb = self.build(url)
        curb.headers["Expect:"] = ''
        curb.http_post(*fields)
        CurbFu::Response::Base.create(curb)
      end
      
      def post_file(url, params = {}, filez = {})
        fields = []
        params.each do |name, value|
          fields << Curl::PostField.content(name,value)
        end
        filez.each do |name, path|
          fields << Curl::PostField.file(name, path)
        end
        
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
    end
  end
end