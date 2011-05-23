require 'tempfile'
require 'wrapper/report'

def wrap(path, command)
  puts "wrapping #{command}"
  
  $stdout.sync = true
  
  logfile = Tempfile.new("ginko_logs")
  File.open(logfile, "w") do |log|
  
    IO.popen([
                {"RUBYLIB" => path},
                path + "/" + command,
                :err => [:child, :out]]) { |f|
      until f.eof?
        line = f.gets
        log << line
        puts line
      end
    }
  end
  
  puts "#{command} exited with code #{$?}"
  if $? != 0
    puts "preparing report"
    
    #Gtk.main_do_event
    report = Report.new(logfile)
    report.show_send_report_question
  end
end