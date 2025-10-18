class MinimumPurchaseRule < Rule
  attribute :properties, :json, default: -> { 
    {'minimum_amount' => 0, 'discount_amount' => 0} 
  }
  
  def minimum_amount
    properties['minimum_amount'] || 0
  end
  
  def minimum_amount=(value)
    properties['minimum_amount'] = value.to_f
  end
  
  def discount_amount
    properties['discount_amount'] || 0
  end
  
  def discount_amount=(value)
    properties['discount_amount'] = value.to_f
  end

  protected

  def transform(context)
    if context.current_price >= minimum_amount
      discount = discount_amount
      previous_price = context.current_price
      
      context.current_price = [context.current_price - discount, 0].max
      
      context.applied_rules << {
        name: self.name,
        type: "Minimum Purchase Discount",
        minimum_required: minimum_amount,
        discount: discount,
        previous_price: previous_price,
        new_price: context.current_price
      }
    end
    
    context
  end
end