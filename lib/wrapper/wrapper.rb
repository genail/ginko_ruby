
def wrap(path, command)
  puts "wrapping #{command}"
  
  $stdout.sync = true
  
  IO.popen([{"RUBYLIB" => path}, path + "/" + command]) { |f|
    until f.eof?
      puts f.gets
    end
  }
  
  puts "#{command} exited with code #{$?}"
end