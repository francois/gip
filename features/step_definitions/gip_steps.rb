Given /^a project$/ do
  @project_dir = Pathname.new(Dir.tmpdir) + "gip/#{Process.pid}/project-dir"
  FileUtils::Verbose.rm_rf(@project_dir)
  @project_dir.mkpath
  Dir.chdir(@project_dir) do
    sh "touch README", :verbose => true
    sh "git init", :verbose => true
    sh "git add --all", :verbose => true
    sh "git commit --message 'Initial commit'", :verbose => true
    sh "ls -A", :verbose => true
  end
end
