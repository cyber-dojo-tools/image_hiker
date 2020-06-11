require_relative 'languages_start_points_service'
require_relative 'runner_service'
require 'net/http'

class External

  def initialize(options = {})
    @http = options['http'] || Net::HTTP
    @languages = LanguagesStartPointsService.new(self)
    @runner = RunnerService.new(self)
  end

  attr_reader :languages
  attr_reader :runner
  attr_reader :http

end
