class Result
  attr_reader :original_price, :final_price, :applied_rules, :total_savings, :metadata

  def initialize(context)
    @original_price = context.original_price
    @final_price = context.current_price
    @applied_rules = context.applied_rules
    @metadata = context.metadata
    @total_savings = @original_price - @final_price
  end

  def breakdown
    return "No discounts applied" if applied_rules.empty?
    
    applied_rules.map.with_index do |rule, index|
      "#{index + 1}. #{rule[:name]} - #{rule[:type]}: #{format_rule(rule)}"
    end.join("\n")
  end
  
  def savings_percentage
    return 0 if original_price.zero?
    ((total_savings / original_price) * 100).round(2)
  end

  private

  def format_rule(rule)
    details = rule.except(:type, :previous_price, :new_price)
    details.map { |k, v| "#{k}: #{v}" }.join(", ")
  end
end