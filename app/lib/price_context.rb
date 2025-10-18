class PriceContext
  attr_accessor :original_price, :current_price, :applied_rules, :metadata

  def initialize(original_price, metadata = {})
    @original_price = original_price
    @current_price = original_price
    @applied_rules = []
    @metadata = metadata
  end
end