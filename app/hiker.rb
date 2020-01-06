
class Hiker

  def initialize(external)
    @external = external
  end

  def hike(colour)
    names = languages_start_points.names
    name = names[0]
    manifest = languages_start_points.manifest(name)
    image_name = manifest['image_name']
    id = '34de2W'
    files = files_from(manifest)
    filename = files.select{|file,content| content.include?('6 * 9')}.keys[0]
    files[filename].sub!('6 * 9', SUB_TEXT[colour])
    result = traffic_light(image_name, id, files)
    if result === {'colour'=>colour}
      puts "Testing #{colour} PASSED"
      exit(0)
    else
      line_split(result, 'stdout')
      line_split(result, 'stderr')
      line_split(result, 'source')
      line_split(result, 'message')
      puts JSON.pretty_generate(result)
      puts "Testing #{colour} FAILED"
      exit(42)
    end
  end

  private

  SUB_TEXT = {
    'red'   => '6 * 9',
    'amber' => '6 * 9sdsd',
    'green' => '6 * 7'
  }

  def line_split(hash, key)
    if hash.has_key?('diagnostic')
      if hash['diagnostic'].has_key?(key)
        hash['diagnostic'][key] = hash['diagnostic'][key].lines
      end
    end
  end

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

  def languages_start_points
    @external.languages_start_points
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
hiker.hike(ARGV[0])
