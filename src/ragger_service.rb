require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'

class RaggerService

  def initialize(external)
    requester = HttpJson::RequestPacker.new(external, 'ragger', 5537)
    @http = HttpJson::ResponseUnpacker.new(requester)
  end

  def ready?
    @http.get(__method__, {})
  end

  def colour(image_name, id, stdout, stderr, status)
    @http.get(__method__, {
      image_name:image_name,
      id:id,
      stdout:stdout,
      stderr:stderr,
      status:status
    })
  end

end
