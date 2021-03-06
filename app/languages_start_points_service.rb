require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'

class LanguagesStartPointsService

  def initialize(external)
    requester = HttpJson::RequestPacker.new(external, 'traffic-light-lsp', 4524)
    @http = HttpJson::ResponseUnpacker.new(requester, { raw:true })
  end

  def manifests
    @http.get(__method__, {})
  end

  def manifest(name)
    @http.get(__method__, { name:name })
  end

end
