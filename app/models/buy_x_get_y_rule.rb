class BuyXGetYRule < Rule
  attribute :properties, :json, default: -> { 
    {'required_quantity' => 2, 'free_quantity' => 1} 
  }
  
  def required_quantity
    properties['required_quantity'] || 0
  end
  
  def required_quantity=(value)
    properties['required_quantity'] = value.to_i
  end
  
  def free_quantity
    properties['free_quantity'] || 0
  end
  
  def free_quantity=(value)
    properties['free_quantity'] = value.to_i
  end

  protected

  def transform(context)
    quantity = context.metadata[:quantity] || 0
    
    if quantity >= required_quantity
      sets = quantity / required_quantity
      free_items = sets * free_quantity
      
      context.metadata[:free_items] = (context.metadata[:free_items] || 0) + free_items
      
      context.applied_rules << {
        name: self.name,
        type: "Buy X Get Y",
        required_quantity: required_quantity,
        free_quantity: free_quantity,
        total_free_items: free_items
      }
    end
    
    context
  end
end