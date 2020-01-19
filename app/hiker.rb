# frozen_string_literal: true
require 'json'

class Hiker

  def initialize(external)
    @external = external
  end

  # - - - - - - - - - - - - - - - - - - -

  def hike(colour)
    # TODO: exit(42) unless %w( red amber green ).include?(colour)
    image_name = manifest['image_name']
    id = '999999'
    files = Hash[
      manifest['visible_filenames'].map { |filename|
        [ filename, IO.read("#{base_dir}/#{filename}") ]
      }
    ]
    filename,from,to = hiker_substitutions(files, colour)
    files[filename].sub!(from, to)
    $stdout.print("Testing #{colour.rjust(5)}: #{filename} '#{from}' ")
    unless from === to
      $stdout.print("=> '#{to}' ")
    end
    $stdout.flush
    actual = traffic_light(image_name, id, files)
    if actual === colour
      puts 'PASSED'
      exit(0)
    else
      puts 'FAILED'
      split_run(result, 'stdout')
      split_run(result, 'stderr')
      split_run_array(result, 'created')
      split_run_array(result, 'changed')
      puts JSON.pretty_generate(result)
      exit(42)
    end
  end

  private

  def hiker_substitutions(files, colour)
    if options?
      puts "Using #{options_filename}"
      json = JSON.parse!(IO.read(options_filename))[colour]
      [ json['filename'], json['from'], json['to'] ]
    else
      # '6 * 9' could match '6 * 99'... tighten with a more precise regex?
      filename = files.keys.find{|filename| files[filename].include?('6 * 9')}
      if filename.nil?
        puts "ERROR: none of the manifest['visible_files'] include the"
        puts "       string '6 * 9' and there is no 'options.json' file."
        exit(42)
      end
      [ filename, '6 * 9', TEXT_SUB[colour] ]
    end
  end

  def options?
    File.file?(options_filename)
  end

  def options_filename
    "#{base_dir}/options.json"
  end

  # - - - - - - - - - - - - - - - - - - -

  def base_dir
    "#{ENV['SRC_DIR']}/start_point"
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest
    @manifest ||= JSON.parse!(IO.read("#{base_dir}/manifest.json"))
  end

  # - - - - - - - - - - - - - - - - - - -

  TEXT_SUB = {
    'red'   => '6 * 9',
    'amber' => '6 * 9sd',
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
    result = runner.run_cyber_dojo_sh(image_name, id, files, max_seconds=10)
    result['timed_out'] || result['colour']
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
colour = ARGV[0]
hiker.hike(colour)
