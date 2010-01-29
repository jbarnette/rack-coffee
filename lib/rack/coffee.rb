require 'time'
require 'coffee-script'
require 'rack/file'
require 'rack/utils'

module Rack
  class Coffee
    F = ::File
    
    attr_accessor :url, :root
    
    def initialize(app, opts={})
      @app = app
      @url = opts[:url] || '/javascripts'
      @root = opts[:root] || Dir.pwd
      @server = Rack::File.new(root)
    end
    
    def call(env)
      path = Utils.unescape(env["PATH_INFO"])
      return [403, {"Content-Type" => "text/plain"}, ["Forbidden\n"]] if path.include?('..')
      return @app.call(env) unless (path.index(url) == 0) and (path =~ /\.js$/)
      coffee = F.join(root, path.sub(/\.js$/,'.coffee'))
      if F.file?(coffee)
        headers = {"Content-Type" => "application/javascript", "Last-Modified" => F.mtime(coffee).httpdate}
        [200, headers, [CoffeeScript.compile(F.read(coffee))]]
      else
        @server.call(env)
      end
    end
    
  end
end