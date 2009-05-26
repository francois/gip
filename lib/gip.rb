require "thor"
require "uri"
require "csv"

class Gip < Thor
  desc  "import REPOSITORY_URL [target]", <<DESC
Imports the repository at target in the current tree.

If target is absent, the repository's base name will be used.
--remote specifies the name of the remote. If unspecified, the repository's base name will be used.
--commit specifies which commit to import.  If unspecified, 'REMOTE/master' will be used.  You can use any <tree-ish> that Git will recognize (SHA-1, branch name, tag name).  The remote's name will always be prefixed to this value.

In all cases, a .gipinfo file will be created/updated with the correct remotes specified.  The .gipinfo file is a CSV file with 2 columns: remote name,repository URL.
DESC
  method_options :commit => :optional, :remote => :optional, :verbose => 0
  def import(repository_url, target=nil)
    uri         = URI.parse(repository_url)
    target      = File.basename(uri.path).sub(File.extname(uri.path), "") unless target
    remote_name = options[:remote]
    remote_name = File.basename(uri.path).sub(File.extname(uri.path), "") unless remote_name
    commit      = options[:commit]
    commit      = "master" unless commit
    commit      = "#{remote_name}/#{commit}"
    puts "Importing #{repository_url} into #{target} at #{commit}"

    create_remote remote_name, repository_url
    git :fetch, remote_name
    git :"read-tree", "--prefix=#{target}/", "-u", commit
    gipinfo(remote_name => repository_url)
    git :add, ".gipinfo"
    git :commit, "-m", "Vendored #{repository_url} at #{commit}", :verbose => true
  end

  desc "Creates or updates remotes in this repository", <<DESC
Given the remotes described in a .gipinfo, creates or updates Git remotes in this repository.
DESC
  method_options :verbose => 0
  def remotify
    read_gipinfo.each do |remote_name, repository_url|
      create_remote(remote_name, repository_url)
      git :fetch, remote_name
    end
  end

  private
  def create_remote(remote_name, repository_url)
    git :remote, :add, remote_name, repository_url
  rescue CommandError => e
    # 128 means remote already exists
    raise unless e.exitstatus == 128
  end

  def gipinfo(remotes)
    info = read_gipinfo
    info.merge!(remotes)
    write_gipinfo(info)
  end

  def read_gipinfo
    if File.file?(".gipinfo")
      CSV.read(".gipinfo").inject(Hash.new) do |hash, (name,url)|
        next hash if name =~ /\s*#/
        hash[name] = url
        hash
      end
    else
      Hash.new
    end
  end

  def write_gipinfo(remotes)
    CSV.open(".gipinfo", "w") do |io|
      io << ["# This is the GIP gipinfo file.  See http://github.com/francois/gip for details.  Gip is a RubyGem:  sudo gem install francois-gip."]
      io << ["# This file maps a series of remote names to repository URLs.  This file is here to ease the work of your team."]
      io << ["# Run 'gip remotify' to generate the appropriate remotes in your repository."]

      remotes.each do |name,url|
        io << [name, url]
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
end
