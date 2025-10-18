class Rule < ApplicationRecord
  def apply(price_context)
    transform(price_context)
  end

  protected

  def transform(price_context)
    raise NotImplementedError, "Subclasses must implement the transform method"
  end
end
