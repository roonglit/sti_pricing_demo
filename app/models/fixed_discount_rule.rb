class FixedDiscountRule < Rule
  attribute :properties, :json, default: -> { {'amount' => 0}}

  validates :properties, presence: true
  validate :amount_must_be_positive

  def amount
    properties['amount'] || 0
  end

  def amount=(value)
    properties['amount'] = value.to_f
  end

  protected

  def transform(context)
    discount = amount
    previous_price = context.current_price

    # Ensure price does not go below zero
    context.current_price = [context.current_price - discount, 0].max

    context.applied_rules << {
      name: self.name,
      type: 'Fixed Discount',
      amount: discount,
      previous_price: previous_price,
      new_price: context.current_price
    }

    context
  end

  private

  def amount_must_be_positive
    errors.add(:amount, "must be positive") if amount < 0
  end

end