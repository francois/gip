require "thor"
require "uri"
require "csv"

class Gip < Thor
  map %w(--version -v) => :version, %w(--help -h) => :help

  def version
    print "Gip v"
    puts File.read(File.dirname(__FILE__) + "/../VERSION")
  end

  desc  "import REPOSITORY_URL [path]", <<DESC
Imports the repository at path in the current tree.

If path is absent, the repository's base name will be used.
--remote specifies the name of the remote. If unspecified, the repository's base name will be used.
--commit specifies which commit to import.  If unspecified, 'REMOTE/master' will be used.  You can use any <tree-ish> that Git will recognize (SHA-1, branch name, tag name).  The remote's name will always be prefixed to this value.

In all cases, a .gipinfo file will be created/updated with the correct remotes specified.  The .gipinfo file is a CSV file with 2 columns: remote name,repository URL.
DESC
  method_options :commit => :optional, :remote => :optional, :verbose => 0
  def import(repository_url, path=nil)
    uri  = URI.parse(repository_url)
    path = File.basename(uri.path).sub(File.extname(uri.path), "") unless path
    name = options[:remote]
    name = File.basename(uri.path).sub(File.extname(uri.path), "") unless name

    remote = Remote.new(name, repository_url, path)
    commit = extract_commit(remote)
    puts "Importing #{remote.url} into #{remote.path} at #{commit}"

    create_remote remote.name, remote.url
    git :fetch, remote.name
    git :"read-tree", "--prefix=#{remote.path}/", "-u", commit
    gipinfo(remote)
    git :add, ".gipinfo"
    git :commit, "-m", "Vendored #{repository_url} at #{commit}", :verbose => true
  end

  desc "Creates or updates remotes in this repository", <<DESC
Given the remotes described in a .gipinfo, creates or updates Git remotes in this repository.
DESC
  method_options :verbose => 0
  def remotify
    read_gipinfo.each do |remote|
      create_remote(remote.name, remote.url)
      git :fetch, remote.name
    end
  end

  desc "Freshens the tree at PATH", <<DESC
Given a previously imported tree at PATH, updates it to the latest HEAD, or whatever --commit specifies.

--commit defaults to 'master', and will always be prefixed with the remote's name.
DESC
  method_options :verbose => 0, :commit => :optional
  def update(path=nil)
    read_gipinfo.each do |remote|
      next unless remote.path == path
      commit = extract_commit(remote)
      puts "Freshening #{remote.path} from #{remote.url} to #{commit}"

      create_remote remote.name, remote.url
      git :fetch, remote.name
      git :merge, "-s", :subtree, "#{remote.name}/#{commit}", :verbose => true
    end
  end

  private
  def extract_commit(remote)
    commit = options[:commit]
    commit = "master" unless commit
    commit = "#{remote.name}/#{commit}"
  end

  def create_remote(remote_name, repository_url)
    git :remote, :add, remote_name, repository_url
  rescue CommandError => e
    # 128 means remote already exists
    raise unless e.exitstatus == 128
  end

  def gipinfo(remote)
    info = read_gipinfo
    info << remote
    write_gipinfo(info)
  end

  def read_gipinfo
    if File.file?(".gipinfo")
      CSV.read(".gipinfo").inject(Array.new) do |memo, (name, url, path)|
        next memo if name =~ /^\s*#/
        memo << Remote.new(name, url, path)
      end
    else
      Array.new
    end
  end

  def write_gipinfo(remotes)
    CSV.open(".gipinfo", "w") do |io|
      io << ["# This is the GIP gipinfo file.  See http://github.com/francois/gip for details.  Gip is a RubyGem:  sudo gem install francois-gip."]
      io << ["# This file maps a series of remote names to repository URLs.  This file is here to ease the work of your team."]
      io << ["# Run 'gip remotify' to generate the appropriate remotes in your repository."]

      remotes.each do |remote|
        io << remote.to_a
      end
    end
  end

  def git(*args)
    run_cmd :git, *args
  end

  def run_cmd(executable, *args)
    opts = args.last.is_a?(Hash) ? args.pop : Hash.new

    args.collect! {|arg| arg.to_s =~ /\s|\*|\?|"|\n|\r/ ? %Q('#{arg}') : arg}
    args.collect! {|arg| arg ? arg : '""'}
    cmd = %Q|#{executable} #{args.join(' ')}|
    p cmd if options[:verbose] > 0

    original_language = ENV["LANGUAGE"]
    begin
      ENV["LANGUAGE"] = "C"
      value = run_real(cmd)
      p value    if options[:verbose] > 1 && !value.to_s.strip.empty?
      puts value if opts[:verbose]
      return value
    ensure
      ENV["LANGUAGE"] = original_language
    end
  end

  begin
    raise LoadError, "Not implemented on Win32 machines" if RUBY_PLATFORM =~ /mswin32/
    require "open4"

    def run_real(cmd)
      begin
        pid, stdin, stdout, stderr = Open4::popen4(cmd)
        _, cmdstatus = Process.waitpid2(pid)
        raise CommandError.new("#{cmd.inspect} exited with status: #{cmdstatus.exitstatus}\n#{stderr.read}", cmdstatus) unless cmdstatus.success? || cmdstatus.exitstatus == 1
        return stdout.read
      rescue Errno::ENOENT
        raise BadCommand, cmd.inspect
      end
    end

  rescue LoadError
    # On platforms where open4 is unavailable, we fallback to running using
    # the backtick method of Kernel.
    def run_real(cmd)
      out = `#{cmd}`
      raise BadCommand, cmd.inspect if $?.exitstatus == 127
      raise CommandError.new("#{cmd.inspect} exited with status: #{$?.exitstatus}", $?) unless $?.success? || $?.exitstatus == 1
      out
    end
  end

  class BadCommand < StandardError; end
  class CommandError < StandardError
    def initialize(message, status)
      super(message)
      @status = status
    end

    def exitstatus
      @status.exitstatus
    end
  end

  class Remote
    attr_accessor :name, :url, :path

    def initialize(name, url, path)
      @name, @url, @path = name, url, path
    end

    def to_a
      [@name, @url, @path]
    end
  end
end
