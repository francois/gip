$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require "gip"
require "pathname"
require "fileutils"

require "test/unit/assertions"

module GipHelpers
  def project_dir
    @project_dir ||= begin
                       path = Pathname.new(Dir.tmpdir) + "gip/#{Process.pid}/project-dir"
                       path.mkpath
                       path
                     end
  end

  def reset_vendors!
    @vendor_dirs ||= Hash.new
    @vendor_dirs.values.each {|dir| dir.rmtree }
    @vendor_dirs.clear
  end

  attr_reader :vendor_dirs

  def vendor(basename)
    Pathname.new(Dir.tmpdir) + "gip/#{Process.pid}/#{basename}"
  end
end

World(GipHelpers)
World(Test::Unit::Assertions)

Before do
  reset_vendors!
end
