module Preconditions
  def check_argument(expression, error_message="invalid argument")
    if not expression
      raise error_message
    end
  end
end
