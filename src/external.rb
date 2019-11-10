require_relative 'languages_service'
require_relative 'ragger_service'
require_relative 'runner_service'
require 'net/http'

class External

  def initialize(options = {})
    @http = options['http'] || Net::HTTP
    @languages = LanguagesService.new(self)
    @ragger = RaggerService.new(self)
    @runner = RunnerService.new(self)
  end

  attr_reader :languages, :ragger, :runner
  attr_reader :http

end
