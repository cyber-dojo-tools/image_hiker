require_relative 'runner_service'
require 'net/http'

class External

  def initialize(options = {})
    @http = options['http'] || Net::HTTP
    @runner = RunnerService.new(self)
  end

  attr_reader :runner
  attr_reader :http

end
