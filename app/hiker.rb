
class Hiker

  def initialize(external)
    @external = external
  end

  def hike
    names = languages.names
    name = names[0]
    manifest = languages.manifest(name)
    image_name = manifest['image_name']
    id = '34de2W'
    files = files_from(manifest)
    red_colour = traffic_light(image_name, id, files)
    STDOUT.puts red_colour

    filename = files.select{|file,content| content.include?('6 * 9')}.keys[0]
    files[filename].sub!('6 * 9', '6 * 9sdsd')
    amber_colour = traffic_light(image_name, id, files)
    STDOUT.puts amber_colour

    files[filename].sub!('6 * 9sdsd', '6 * 7')
    green_colour = traffic_light(image_name, id, files)
    STDOUT.puts green_colour

    STDOUT.flush
  end

  private

  def files_from(manifest)
    manifest['visible_files'].each_with_object({}) do |(filename, file),files|
      files[filename] = file['content']
    end
  end

  def traffic_light(image_name, id, files)
    result = runner.run_cyber_dojo_sh(image_name, id, files, max_seconds=10)
    stdout = result['stdout']['content']
    stderr = result['stderr']['content']
    status = result['status']
    ragger.colour(image_name, id, stdout, stderr, status)
  end

  def languages
    @external.languages
  end

  def ragger
    @external.ragger
  end

  def runner
    @external.runner
  end

end

#- - - - - - - - - - - - - - - - - - - -
require_relative 'external'
external = External.new
hiker = Hiker.new(external)
hiker.hike
