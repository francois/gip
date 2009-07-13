Given /^a project$/ do
  Dir.chdir(project_dir) do
    sh "cd #{project_dir}"
    sh "touch README"
    sh "git init"
    sh "git add --all"
    sh "git commit --message 'Initial commit'"
    sh "ls -A"
  end
end

Given /^a vendor project named "([^"]+)"$/ do |name|
  vendor(name) do |path|
    sh "cd #{path}"
    sh "touch README"
    sh "mkdir lib"
    sh "touch lib/#{name}.rb"
    sh "git init", :verbose => true
    sh "git add --all", :verbose => true
    sh "git commit --message 'Initial commit'", :verbose => true
    sh "ls -lA", :verbose => true
  end
end

When /^I run "gip import __([^_]+)__ ([^"]+)"$/ do |vendor, target|
  Dir.chdir(project_dir) do
    sh "gip import #{vendor_dirs[vendor]}/.git #{target}", :verbose => true
  end
  pending
end

Then /^I should see "([^\"]*)"$/ do |arg1|
  pending
end

Then /^the file '\.gipinfo' should contain 'vendor\/libcalc,__libcalc__'$/ do
  pending
end

Then /^the working copy should be clean$/ do
  pending
end
