module Ginko::Format
  class SizeFormat
    POSTFIX_BYTE = "B"
    
    BASE = {
      "E" => 2**60,
      "P" => 2**50,
      "T" => 2**40,
      "G" => 2**30,
      "M" => 2**20,
      "K" => 2**10,
      "B" => 2**0,
    }
    
    METHOD_SEPARATE = 1 # e.g 123 456 789
    METHOD_HUMAN_READABLE = 2 # eg. 1,1 M
    
    attr_accessor :method
    
    def initialize
      @method = METHOD_SEPARATE
    end
    
    def format(size)
      case @method
        when METHOD_SEPARATE
          format_separated_bytes(size)
        when METHOD_HUMAN_READABLE
          format_human_readable(size)
      end
    end
    
    def format_separated_bytes(size)
      return "0" if size == 0
      
      str = size.to_s # insert?
      s = (str.size / 3.0).ceil - 1
      s.times do |i|
        i1 = i + 1
        str.insert((-3 * i1) - i1, " ")
      end
      
      str
    end
    
    def format_human_readable(size)
      return "0 #{POSTFIX_BYTE}" if size == 0
      
      BASE.each do |postfix, base|
        if size >= base
          
          if base == 1
            return "#{size} #{postfix}"
          else
            f = size / base.to_f
            return "%.1f %s" % [f, postfix]
          end
        end
      end
    end
  end
end
