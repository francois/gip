$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require "gip"
require "pathname"
require "fileutils"

require "test/unit/assertions"

World(Test::Unit::Assertions)
