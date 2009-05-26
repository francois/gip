def sh(command_line, options={})
  verbose = $DEBUG || options[:verbose]
  puts "CWD:#{Dir.pwd}"      if verbose
  p command_line             if verbose
  result = `#{command_line}`
  p $?                       if verbose
  puts "===="                if verbose
  puts result                if verbose
  puts "===="                if verbose
  result
end
