
class Hiker

  def initialize(external)
    @external = external
  end

  def sha
    ENV['SHA']
  end

  def ready?
    languages.ready? && ragger.ready? && runner.ready?
  end

  def hike
    names = languages.names
    name = names[0]
    manifest = languages.manifest(name)
    image_name = manifest['image_name']
    id = '34de2W'
    files = files_from(manifest)
    colour1 = traffic_light(image_name, id, files)
    files['hiker.c'].sub!('6 * 9', '6 * 9sdsd')
    colour2 = traffic_light(image_name, id, files)
    files['hiker.c'].sub!('6 * 9sdsd', '6 * 7')
    colour3 = traffic_light(image_name, id, files)

    STDOUT.puts names
    STDOUT.puts image_name
    STDOUT.puts id
    STDOUT.puts colour1
    STDOUT.puts colour2
    STDOUT.puts colour3
    STDOUT.flush
  end

  private

  def files_from(manifest)
    Hash[manifest['visible_files'].map do |filename, file|
      [filename,file['content']]
    end]
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

  def log
    @external.log
  end

end
