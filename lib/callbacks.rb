module Callbacks
  
  def CallbackStore
    def initialize
      @callbacks = []
    end
    
    def add(callback)
      @callbacks << callback
    end
    
    def call(*args)
      @callbacks.each { |c| c.call(*args) }
    end
  end
  
  def Callback
    def initialize(*args, &block)
      @args = args
      @block = block
    end
    
    def call(*args)
      if @args.empty? or args == @args
        block.call(args)
      end
    end
  end
  
  def callback(*names)
    names.each do |name|
      class_eval <<-EOF
        def #{name}(*args, &block)
          if block
            @#{name} = block
          elsif @#{name}
            @#{name}.call(*args)
          end
        end
      EOF
    end
  end
  
end
