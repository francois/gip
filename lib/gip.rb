require "thor"
require "uri"

class Gip < Thor
  desc  "import REPOSITORY_URL [target]",
        "Imports the repository at target in the current tree.  If target is absent, the repository's base name will be used.  If --commit is specified, that commit will be imported, else HEAD."
  method_options :commit => :optional
  def import(repository_url, target=nil)
    uri = URI.parse(repository_url)
    target = File.basename(uri.path).sub(File.extname(uri.path), "") unless target
    puts "Importing #{repository_url} into #{target} at #{options[:commit] || 'HEAD'}"
  end
end
