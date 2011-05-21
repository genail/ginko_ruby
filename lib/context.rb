module Ginko
  class Context
    attr_accessor :main_window
    
    def add_accel(key, mods, flags, &closure)
      guard(closure)
      
      ag = Gtk::AccelGroup.new
      guard(ag)
      ag.connect(key, mods, flags, &closure)
      @main_window.add_accel_group(ag)
    end
    
    #######
    private
    #######
    
    def guard(closure)
      @guard ||= []
      @guard << closure
    end
  end
end
