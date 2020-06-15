# frozen_string_literal: true
require 'json'

class Hiker

  def initialize(external)
    @external = external
  end

  # - - - - - - - - - - - - - - - - - - -

  def hike(colour)
    raw = manifest['visible_files']
    files = raw.map.with_object({}) do |(filename,file),memo|
      memo[filename] = file['content']
    end
    filename,from,to = hiker_6x9_substitutions(files, colour)
    files[filename].sub!(from, to)

    t1 = Time.now
    result = run_cyber_dojo_sh(id='999999', files, manifest)
    t2 = Time.now

    split_run(result, 'stdout')
    split_run(result, 'stderr')
    split_run_array(result, 'created')
    split_run_array(result, 'changed')
    puts JSON.pretty_generate(result)

    puts "\n"
    outcome = (result['colour'] === colour) ? 'PASSED' : 'FAILED'
    puts JSON.pretty_generate(
      'runner_sha' => runner.sha,
      'max_seconds' => manifest['max_seconds'],
      'filename' => filename,
      'from' => from,
      'to' => to,
      'duration' => (t2 - t1),
      'colour' => colour,
      'outcome' => outcome
    )
    puts "\n"
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
      name = languages.manifests['manifests'].keys[0]
      manifest = languages.manifest(name)['manifest']
      manifest['max_seconds'] ||= 10
      manifest
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

  def run_cyber_dojo_sh(id, files, manifest)
    runner.run_cyber_dojo_sh(id, files, manifest)
  end

  # - - - - - - - - - - - - - - - - - - -

  def languages
    @external.languages
  end

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
