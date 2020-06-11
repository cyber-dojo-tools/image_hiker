require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'

class RunnerService

  def initialize(external)
    requester = HttpJson::RequestPacker.new(external, 'traffic-light-runner', 4597)
    @http = HttpJson::ResponseUnpacker.new(requester)
  end

  def sha
    @http.get(__method__, {})
  end

  def run_cyber_dojo_sh(id, files, manifest)
    @http.get(__method__, {
      id:id,
      files:files,
      manifest:manifest
    })
  end

end
