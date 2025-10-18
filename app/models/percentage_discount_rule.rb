class PercentageDiscountRule < Rule
  attribute :properties, :json, default: -> { {'percentage' => 0} }

  validates :properties, presence: true
  validate :percentage_must_be_valid
  
  def percentage
    properties['percentage'] || 0
  end
  
  def percentage=(value)
    properties['percentage'] = value.to_f
  end

  protected

  def transform(context)
    discount_percentage = percentage
    discount_amount = context.current_price * (discount_percentage / 100.0)
    previous_price = context.current_price
    
    context.current_price = context.current_price - discount_amount
    
    context.applied_rules << {
      name: self.name,
      type: "Percentage Discount",
      percentage: discount_percentage,
      discount_amount: discount_amount.round(2),
      previous_price: previous_price,
      new_price: context.current_price
    }
    
    context
  end
  
  private
  
  def percentage_must_be_valid
    if percentage <= 0 || percentage > 100
      errors.add(:percentage, "must be between 0 and 100")
    end
  end
end