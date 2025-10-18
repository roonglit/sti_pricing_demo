class LoyaltyPointsRule < Rule
  def transform(context)
    points = context.metadata[:loyalty_points] || 0
    discount = points * 0.01 # $0.01 per point
    
    context.current_price -= discount
    context.applied_rules << {
      name: self.name,
      type: "Loyalty Points",
      points_used: points,
      discount: discount
    }
    context
  end
end