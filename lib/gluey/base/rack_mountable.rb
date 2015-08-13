require 'rack/utils'

module Gluey
  class RackMountable
    ALLOWED_HEADERS = %w[GET HEAD].freeze
    PATH_PARSER = %r_^/?(\w+)/([^\.]+)(?:\.([a-f0-9]{32}))?\.\w+$_

    def initialize(env, logger)
      @environment = env
      @logger = logger
    end

    def call(env)
      material = nil
      path = nil
      start_time = Time.now.to_f
      time_elapsed = lambda { ((Time.now.to_f - start_time) * 1000).to_i }

      unless ALLOWED_HEADERS.include? env['REQUEST_METHOD']
        return method_not_allowed_response
      end

      # Extract the path from everything after the leading slash
      @logger.info "##### PATH_INFO: #{env['PATH_INFO']} #####"
      _, material, path, mark = env['PATH_INFO'].to_s.match(PATH_PARSER).to_a
      unless path
        return bat_path_response
      end

      file = @environment[material, path, mark]
      unless file
        @logger.info "Not found glued asset #{path}, material=#{material} - 404 (#{time_elapsed.call}ms)"
        return not_found_response
      end

      @logger.info "Served glued asset #{path}, material=#{material} - 200 (#{time_elapsed.call}ms)"
      ok_response file

    rescue => e
      @logger.error "Error gluying asset #{path}, material=#{material}:"
      @logger.error "#{e.class.name}: #{e.message}"
      raise
    end

    private

    # Returns a 200 OK response tuple
    def ok_response(file)
      headers = {
          'Content-Length' => File.stat(file).size,
          'Content-Type' => Rack::Mime.mime_type(File.extname(file), 'text/plain')
      }
      if @environment.mark_versions
        headers['Cache-Control'] = "public, max-age=31536000"
      end

      [200, headers, FileBody.new(file)]
    end

    def method_not_allowed_response
      [405, {'Content-Type' => "text/plain", 'Content-Length' => "18"}, ['Method Not Allowed']]
    end

    def bat_path_response
      [400, {'Content-Type' => "text/plain", 'Content-Length' => "8"}, ['Bad Path']]
    end

    # Returns a 404 Not Found response tuple
    def not_found_response
      [404, {'Content-Type' => "text/plain", 'Content-Length' => "9"}, ['Not found']]
    end

    class FileBody < Struct.new(:file_path)
      def each
        File.open(file_path, 'rb') do |file|
          while chunk = file.read(16384)
            yield chunk
          end
        end
      end
    end

  end
end