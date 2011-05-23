require 'gtk2'

require "uri"
require "net/http"

class Report
  def initialize(report_file)
    @report_file = report_file
  end
  
  def show_send_report_question
    dialog = Gtk::MessageDialog.new(nil,
                  0,
                  Gtk::MessageDialog::ERROR,
                  Gtk::MessageDialog::BUTTONS_YES_NO,
                  "Oh crap! Looks like Ginko just crashed! Do you want to " +
                  "send anonymous error report from #{@report_file.path} to " +
                  " the greatest person " +
                  "in the world? (author of this app - yes, that's me!)")
    dialog.run do |response|
      case response
        when Gtk::Dialog::RESPONSE_YES
          send_report
          show_your_thanks
      end
    end
  end
  
  def send_report
    params = {"c" => @report_file.read}
    x = Net::HTTP.post_form(
          URI.parse('http://chudy.rootnode.net/ginko/report.php'), params)
  end
  
  def show_your_thanks
    dialog = Gtk::MessageDialog.new(nil,
                  0,
                  Gtk::MessageDialog::INFO,
                  Gtk::MessageDialog::BUTTONS_OK,
                  "Thanks a lot!")
    dialog.run
  end
end
