require 'json'

class Hiker

  def initialize(external)
    @external = external
  end

  # - - - - - - - - - - - - - - - - - - -

  def hike(colour)
    files = visible_files
    filename,from,to = hiker_6x9_substitutions(files, colour)
    files[filename].sub!(from, to)
    report(files, colour, {
      'filename' => filename,
      'from' => from,
      'to' => to
    })
  end

  # - - - - - - - - - - - - - - - - - - -

  # Runs the files of one fixture dir, which holds the source and test files
  # of a kata a learner has edited into a state the three 6*9 substitutions
  # cannot express, such as a second test file or a file that will not parse.
  #
  # The dir is named for the colour it should reach, so the expectation
  # travels with the case rather than living in a table that can drift.
  def hike_fixture(fixture_dir)
    name = File.basename(fixture_dir)
    report(fixture_files(fixture_dir), expected_outcome(name), {
      'fixture' => name
    })
  end

  private

  # - - - - - - - - - - - - - - - - - - -

  OUTCOMES = %w( timed_out faulty red amber green )

  # Echoes the outcome a fixture dir's name says it should reach.
  #
  # The longest match wins, so timed_out is read whole rather than as timed.
  # A name matching none of them is a typo, and saying so beats running the
  # case and reporting that it did not reach an outcome nothing can reach.
  def expected_outcome(name)
    outcome = OUTCOMES.find { |outcome| name.start_with?("#{outcome}_") }
    if outcome.nil?
      STDERR.puts "ERROR: fixture dir '#{name}' does not start with one of"
      STDERR.puts "       #{OUTCOMES.join(' ')}"
      exit(42)
    end
    outcome
  end

  # - - - - - - - - - - - - - - - - - - -

  # Runs the files and says whether the colour they reached is the colour
  # they were expected to reach.
  def report(files, colour, summary_extras)
    t1 = Time.now
    run_result = run_cyber_dojo_sh(id='999999', files, manifest)
    t2 = Time.now

    split_run(run_result, 'stdout')
    split_run(run_result, 'stderr')
    split_run_array(run_result, 'created')
    split_run_array(run_result, 'changed')

    actual_colour = run_result['outcome']
    result = (actual_colour === colour) ? 'PASSED' : 'FAILED'
    summary = {
      'runner_sha' => runner.sha,
      'max_seconds' => manifest['max_seconds'],
      'duration' => (t2 - t1),
      'colour' => actual_colour,
      'result' => result
    }.merge(summary_extras)

    puts JSON.pretty_generate({
      'cyber-dojo.sh': run_result,
      'summary': summary
    })
    puts "\n"
    exit (result === 'PASSED') ? 0 : 42
  end

  # - - - - - - - - - - - - - - - - - - -

  def visible_files
    manifest['visible_files'].map.with_object({}) do |(filename,file),memo|
      memo[filename] = file['content']
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  # Echoes the files a kata made from this fixture holds, keyed by the
  # filename the learner sees, nested dirs included.
  #
  # The fixture is authoritative for the source and test files, so a case can
  # rename one, add one, or leave one out. Every other file the start-point
  # ships comes along beside them, because the learner has those too, and
  # cyber-dojo.sh is one of them: a fixture never holds it, since a learner
  # does not edit it and it is the thing these cases put under test.
  def fixture_files(fixture_dir)
    files = scaffolding_files
    glob = File.join(fixture_dir, '**', '*')
    Dir.glob(glob, File::FNM_DOTMATCH).select { |path| File.file?(path) }.each do |path|
      files[path.sub("#{fixture_dir}/", '')] = IO.read(path)
    end
    files
  end

  # - - - - - - - - - - - - - - - - - - -

  # Echoes the shipped files that are not source or test files, such as a
  # build config or a crib sheet, plus cyber-dojo.sh. A source or test file
  # is one whose extension the manifest lists, and those belong to the
  # fixture. cyber-dojo.sh carries one of those extensions in several
  # languages, so it is named rather than filtered for.
  def scaffolding_files
    extensions = manifest['filename_extension']
    visible_files.reject do |filename,_|
      filename != 'cyber-dojo.sh' &&
        extensions.any? { |extension| filename.end_with?(extension) }
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def hiker_6x9_substitutions(files, colour)
    if options?
      # puts "Using #{options_filename}"
      json = JSON.parse!(IO.read(options_filename))[colour]
      [ json['filename'], json['from'], json['to'] ]
    else
      filename = files.keys.find{|filename| files[filename].include?('6 * 9')}
      if filename.nil?
        STDERR.puts "ERROR: none of the manifest['visible_files'] include the"
        STDERR.puts "       string '6 * 9' and there is no 'options.json' file."
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
# Use: hiker.rb red|amber|green
#      hiker.rb --fixture <dir>
require_relative 'external'
external = External.new
hiker = Hiker.new(external)
if ARGV[0] === '--fixture'
  hiker.hike_fixture(ARGV[1])
else
  hiker.hike(ARGV[0])
end
