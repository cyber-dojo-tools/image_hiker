require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'

class RunnerService

  def initialize(external)
    requester = HttpJson::RequestPacker.new(external, 'runner', 4597)
    @http = HttpJson::ResponseUnpacker.new(requester)
  end

  def run_cyber_dojo_sh(image_name, id, files, max_seconds)
    @http.get(__method__, {
      image_name:image_name,
      id:id,
      files:files,
      max_seconds:max_seconds
    })
  end

end
