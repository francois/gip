# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gip}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fran\303\247ois Beausoleil"]
  s.date = %q{2009-09-18}
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
  s.homepage = %q{http://github.com/francois/gip}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Gip into place: Piston without the SVN cruft}
  s.test_files = [
    "test/gip_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thor>, ["~> 0.11"])
    else
      s.add_dependency(%q<thor>, ["~> 0.11"])
    end
  else
    s.add_dependency(%q<thor>, ["~> 0.11"])
  end
end
