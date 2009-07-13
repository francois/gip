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
    @vendor_dirs.values.each {|dir| dir.rmtree }
    @vendor_dirs = Hash.new
  end

  def vendor_dirs
    @vendor_dirs
  end

  def vendor(basename)
    Pathname.new(Dir.tmpdir) / "gip" / Process.pid.to_s / basename
  end
end

World(GipHelpers)
World(Test::Unit::Assertions)

Before do
  reset_vendors!
end
