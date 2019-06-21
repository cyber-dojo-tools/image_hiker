require_relative 'ragger_service'
require_relative 'runner_service'
require_relative 'stdout_log'
require 'net/http'

class External

  def initialize(options = {})
    @http = options['http'] || Net::HTTP
    @log  = options['log' ] || StdoutLog.new
    @ragger = RaggerService.new(self)
    @runner = RunnerService.new(self)
  end

  attr_reader :http, :log, :ragger, :runner

end