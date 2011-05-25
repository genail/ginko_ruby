module Ginko::Format
  class DateFormat
    def format(time)
      time.strftime("%d.%m.%Y %H:%M")
    end
  end
end
