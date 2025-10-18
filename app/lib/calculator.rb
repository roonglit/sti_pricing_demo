class Calculator
  def self.calculate(price_or_context, rules = [])
    # Handle both PriceContext and numeric price
    context = if price_or_context.is_a?(PriceContext)
                price_or_context
              else
                PriceContext.new(price_or_context)
              end

    # Apply each rule in sequence
    rules.each do |rule|
      context = rule.apply(context)
    end

    Result.new(context)
  end
end