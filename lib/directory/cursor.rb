module Ginko::Directory
  class Cursor
    attr_reader :iter
    
    def initialize(view, iter=nil)
      @view = view
      @iter = iter
    end
    
    def visible?
      @iter != nil
    end
    
    def move_up
      if @iter.prev!
        set_on(@iter)
      end
    end
    
    def move_down
      if @iter.next!
        set_on(@iter)
      end
    end
    
    def set_on_first
      @iter = @view.model.iter_first
      
      unless @iter.nil?
        set_on(@iter)
      end
    end
    
    def set_on(iter)
      @view.set_cursor(@iter.path, nil, false)
    end
  end
end
