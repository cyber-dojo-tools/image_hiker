$stdout.sync = true
$stderr.sync = true

require 'rack'
require_relative './src/external'
require_relative './src/hiker'
require_relative './src/rack_dispatcher'

use Rack::Deflater, if: ->(_, _, _, body) { body.any? && body[0].length > 512 }

hiker = Hiker.new(External.new)
run RackDispatcher.new(hiker)
