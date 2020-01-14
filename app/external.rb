require_relative 'languages_start_points_service'
require_relative 'runner_service'
require 'net/http'

class External

  def initialize(options = {})
    @http = options['http'] || Net::HTTP
    @languages_start_points = LanguagesStartPointsService.new(self)
    @runner = RunnerService.new(self)
  end

  attr_reader :languages_start_points, :runner
  attr_reader :http

end
