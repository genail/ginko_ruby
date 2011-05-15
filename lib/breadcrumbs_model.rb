require 'callbacks'

class BreadcrumbsModel
  extend Callbacks
  
  callback :on_path_changed
  
  def initialize
    @path = Pathname.new('/')
  end
  
  def path=(path)
    @path = path
    on_path_changed
  end
  
  attr_reader :path
  
  def path_components
    @path.to_s.split(File::SEPARATOR).delete_if {|x| x.empty?}
  end
  
end
