# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gip}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fran\303\247ois Beausoleil"]
  s.date = %q{2009-07-13}
  s.default_executable = %q{gip}
  s.email = %q{francois@teksol.info}
  s.executables = ["gip"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/gip",
     "features/import.feature",
     "features/step_definitions/gip_steps.rb",
     "features/support/command_line.rb",
     "features/support/env.rb",
     "gip.gemspec",
     "lib/gip.rb",
     "test/gip_test.rb",
     "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/francois/gip}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Gip into place: Piston without the SVN cruft}
  s.test_files = [
    "test/gip_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
