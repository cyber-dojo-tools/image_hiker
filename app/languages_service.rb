require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'

class LanguagesService

  def initialize(external)
    requester = HttpJson::RequestPacker.new(external, 'languages', 4524)
    @http = HttpJson::ResponseUnpacker.new(requester)
  end

  def names
    @http.get(__method__, {})
  end

  def manifest(name)
    @http.get(__method__, { name:name })
  end

end
