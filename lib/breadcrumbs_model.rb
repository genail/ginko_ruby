require 'callbacks'

class BreadcrumbsModel
  extend Callbacks
  
  callback :on_path_changed
  
  def initialize
    @path = '/home/chudy'
  end
  
  def path=(path)
    @path = path
    on_path_changed
  end
  
  attr_reader :path
  
  def path_components
    @path.split(File::SEPARATOR).delete_if {|x| x.empty?}
  end
  
end
