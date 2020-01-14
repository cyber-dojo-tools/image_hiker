
class Hiker

  def initialize(external)
    @external = external
  end

  # - - - - - - - - - - - - - - - - - - -

  def hike(colour)
    names = languages_start_points.names
    name = names[0]
    manifest = languages_start_points.manifest(name)
    image_name = manifest['image_name']
    id = '34de2W'
    files = files_from(manifest)
    filename = files.find{|_file,content| content.include?('6 * 9')}[0]
    files[filename].sub!('6 * 9', TEXT_SUB[colour])
    result = traffic_light(image_name, id, files)

    if result['colour'] === colour
      puts "Testing #{colour} PASSED"
      exit(0)
    else
      split_run(result, 'stdout')
      split_run(result, 'stderr')
      split_run_array(result, 'created')
      split_run_array(result, 'changed')
      split_diagnostic(result, 'rag_lambda')
      split_diagnostic(result, 'message')
      puts JSON.pretty_generate(result)
      puts "Testing #{colour} FAILED"
      exit(42)
    end
  end

  private

  TEXT_SUB = {
    'red'   => '6 * 9',
    'amber' => '6 * 9sdsd',
    'green' => '6 * 7'
  }

  # - - - - - - - - - - - - - - - - - - -

  def split_run(result, key)
    part = result['run_cyber_dojo_sh']
    part[key]['content'] = part[key]['content'].lines
  end

  # - - - - - - - - - - - - - - - - - - -

  def split_run_array(result, key)
    part = result['run_cyber_dojo_sh']
    part[key].each do |filename,file|
      part[key][filename]['content'] = part[key][filename]['content'].lines
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def split_diagnostic(result, key)
    d = result['diagnostic']
    unless d.nil?
      d[key] = d[key].lines
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def files_from(manifest)
    manifest['visible_files'].each_with_object({}) do |(filename, file),files|
      files[filename] = file['content']
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def traffic_light(image_name, id, files)
    runner.run_cyber_dojo_sh(image_name, id, files, max_seconds=10)
  end

  # - - - - - - - - - - - - - - - - - - -

  def languages_start_points
    @external.languages_start_points
  end

  # - - - - - - - - - - - - - - - - - - -

  def runner
    @external.runner
  end

end

#- - - - - - - - - - - - - - - - - - - -
require_relative 'external'
external = External.new
hiker = Hiker.new(external)
hiker.hike(ARGV[0])
