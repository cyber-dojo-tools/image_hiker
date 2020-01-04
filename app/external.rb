require_relative 'languages_start_points_service'
require_relative 'ragger_service'
require_relative 'runner_service'
require 'net/http'

class External

  def initialize(options = {})
    @http = options['http'] || Net::HTTP
    @languages_start_points = LanguagesStartPointsService.new(self)
    @ragger = RaggerService.new(self)
    @runner = RunnerService.new(self)
  end

  attr_reader :languages_start_points, :ragger, :runner
  attr_reader :http

end
