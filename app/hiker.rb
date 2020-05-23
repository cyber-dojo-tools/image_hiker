# frozen_string_literal: true
require 'json'

class Hiker

  def initialize(external)
    @external = external
  end

  # - - - - - - - - - - - - - - - - - - -

  def hike(colour)
    files = manifest['visible_filenames'].map.with_object({}) do |filename,memo|
      memo[filename] = IO.read("#{base_dir}/#{filename}")
    end
    filename,from,to = hiker_6x9_substitutions(files, colour)
    files[filename].sub!(from, to)

    t1 = Time.now
    r = run_cyber_dojo_sh(id='999999', files, manifest)
    t2 = Time.now
    result = r['run_cyber_dojo_sh']

    split_run(result, 'stdout')
    split_run(result, 'stderr')
    split_run_array(result, 'created')
    split_run_array(result, 'changed')
    puts JSON.pretty_generate(result)

    puts JSON.pretty_generate(
      'runner_sha' => runner.sha['sha'],
      'max_seconds' => manifest['max_seconds'],
      'filename' => filename,
      'from' => from,
      'to' => to,
      'duration' => (t2 - t1)
    )

    outcome = (result['colour'] === colour) ? 'PASSED' : 'FAILED'
    puts
    puts("#{outcome}:TRAFFIC_LIGHT:#{colour}:==================================")
    exit (outcome === 'PASSED') ? 0 : 42
  end

  private

  def hiker_6x9_substitutions(files, colour)
    if options?
      puts "Using #{options_filename}"
      json = JSON.parse!(IO.read(options_filename))[colour]
      [ json['filename'], json['from'], json['to'] ]
    else
      # TODO: '6 * 9' could match '6 * 99'... tighten with a more precise regex?
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
    @manifest ||= begin
      json = JSON.parse!(IO.read("#{base_dir}/manifest.json"))
      json['max_seconds'] ||= 10
      json
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  TEXT_SUB = {
    'red'   => '6 * 9',
    'amber' => '6 * 9sd',
    'green' => '6 * 7'
  }

  # - - - - - - - - - - - - - - - - - - -

  def split_run(result, key)
    result[key]['content'] = result[key]['content'].lines
  end

  # - - - - - - - - - - - - - - - - - - -

  def split_run_array(result, key)
    result[key].each do |filename,file|
      result[key][filename]['content'] = result[key][filename]['content'].lines
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def files_from(manifest)
    manifest['visible_files'].each_with_object({}) do |(filename, file),files|
      files[filename] = file['content']
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def run_cyber_dojo_sh(id, files, manifest)
    runner.run_cyber_dojo_sh(id, files, manifest)
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
