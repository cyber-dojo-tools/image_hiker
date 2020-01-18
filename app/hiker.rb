# frozen_string_literal: true
require 'json'

class Hiker

  def initialize(external)
    @external = external
  end

  # - - - - - - - - - - - - - - - - - - -

  def hike(colour)
    base_dir, image_name, files = base_dir_image_name_files
    id = '34de2W'
    filename,from,to = hiker_substitutions(base_dir, files, colour)
    files[filename].sub!(from, to)
    result = traffic_light(image_name, id, files)

    if result['colour'] === colour
      puts "Testing #{colour} PASSED"
      exit(0)
    else
      split_run(result, 'stdout')
      split_run(result, 'stderr')
      split_run_array(result, 'created')
      split_run_array(result, 'changed')
      puts JSON.pretty_generate(result)
      puts "Testing #{colour} FAILED"
      exit(42)
    end
  end

  private

  def base_dir_image_name_files
    src_dir = ENV['SRC_DIR']
    pattern = "#{src_dir}/**/manifest.json"
    manifest_filename = Dir.glob(pattern)[0]
    manifest = JSON.parse!(IO.read(manifest_filename))
    base_dir = File.dirname(manifest_filename)
    image_name = manifest['image_name']
    files = Hash[manifest['visible_filenames'].map { |filename|
        [ filename,
          IO.read("#{base_dir}/#{filename}")
        ]
      }
    ]
    [ base_dir, image_name, files ]
  end

  # - - - - - - - - - - - - - - - - - - -

  def hiker_substitutions(base_dir, files, colour)
    options_filename = "#{base_dir}/options.json"
    if File.file?(options_filename)
      json = JSON.parse!(IO.read(options_filename))[colour]
      [ json['filename'], json['from'], json['to'] ]
    else
      filename = files.find{|_file,content| content.include?('6 * 9')}[0]
      [ filename, '6 * 9', TEXT_SUB[colour] ]
    end
  end

  # - - - - - - - - - - - - - - - - - - -

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

  def runner
    @external.runner
  end

end

#- - - - - - - - - - - - - - - - - - - -
require_relative 'external'
external = External.new
hiker = Hiker.new(external)
hiker.hike(ARGV[0])
