# Rails Single Table Inheritance (STI) Demo

A demonstration project showcasing **Single Table Inheritance (STI)** in Rails 8.1 through a flexible pricing rules engine.

## Overview

This project implements a pricing calculator that applies various discount rules using STI. All rule types are stored in a single `rules` table, with Rails automatically handling the polymorphic behavior based on the `type` column.

## What is Single Table Inheritance?

Single Table Inheritance (STI) is a pattern where multiple related classes are stored in a single database table. Rails uses a `type` column to distinguish between different subclasses, allowing you to:

- Store related objects with shared attributes in one table
- Query all types together or filter by specific types
- Use polymorphic behavior without complex JOINs
- Add new types without schema changes

## Project Structure

```
app/
├── models/
│   ├── rule.rb                       # Abstract parent class
│   ├── fixed_discount_rule.rb        # Subtracts fixed amount
│   ├── percentage_discount_rule.rb   # Applies percentage discount
│   ├── buy_x_get_y_rule.rb          # Buy X Get Y promotions
│   ├── minimum_purchase_rule.rb      # Minimum purchase discounts
│   └── loyalty_points_rule.rb        # Loyalty points redemption
└── lib/
    ├── calculator.rb                  # Rule orchestration service
    ├── price_context.rb              # Data transfer object
    └── result.rb                      # Result wrapper
```

## The STI Implementation

### Database Schema

All rules are stored in a single table:

```ruby
create_table "rules" do |t|
  t.string   :name                    # Rule name
  t.string   :type, null: false       # STI discriminator (class name)
  t.json     :properties, default: {} # Type-specific configuration
  t.boolean  :active, default: true   # Enable/disable flag
  t.integer  :priority, default: 0    # Execution order
  t.datetime :starts_at               # Optional start date
  t.datetime :ends_at                 # Optional end date
  t.timestamps
end
```

**Key Column: `type`**
Rails automatically sets this to the subclass name (`FixedDiscountRule`, `PercentageDiscountRule`, etc.)

### Parent Class: `Rule`

```ruby
class Rule < ApplicationRecord
  def apply(price_context)
    transform(price_context)
  end

  protected

  def transform(price_context)
    raise NotImplementedError, "Subclasses must implement transform"
  end
end
```

### Example Subclass: `FixedDiscountRule`

```ruby
class FixedDiscountRule < Rule
  attribute :properties, :json, default: -> { {'amount' => 0} }

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
end
```

## Rule Types

| Rule Type | Description | Properties |
|-----------|-------------|------------|
| **FixedDiscountRule** | Subtracts a fixed dollar amount | `amount` |
| **PercentageDiscountRule** | Applies a percentage discount | `percentage` (0-100) |
| **BuyXGetYRule** | Buy X items, get Y free | `required_quantity`, `free_quantity` |
| **MinimumPurchaseRule** | Discount when minimum is met | `minimum_amount`, `discount_amount` |
| **LoyaltyPointsRule** | Redeem loyalty points | None (uses metadata) |

## Usage Examples

### Creating Rules

```ruby
# Create different rule types - all stored in 'rules' table
FixedDiscountRule.create(
  name: "Holiday Special",
  properties: { 'amount' => 10.0 },
  priority: 1
)

PercentageDiscountRule.create(
  name: "Summer Sale",
  properties: { 'percentage' => 15.0 },
  priority: 2
)

BuyXGetYRule.create(
  name: "Buy 2 Get 1 Free",
  properties: { 'required_quantity' => 2, 'free_quantity' => 1 },
  priority: 3
)
```

### Querying with STI

```ruby
# Get all rules (all types)
Rule.all
# => [#<FixedDiscountRule>, #<PercentageDiscountRule>, #<BuyXGetYRule>]

# Get only fixed discount rules
FixedDiscountRule.all
# => [#<FixedDiscountRule>]

# Query by active status across all types
Rule.where(active: true)

# STI automatically sets the 'type' column
rule = FixedDiscountRule.create(name: "Test")
rule.type # => "FixedDiscountRule"
```

### Calculating Prices

```ruby
# Load active rules sorted by priority
rules = Rule.where(active: true).order(:priority)

# Calculate final price
result = Calculator.calculate(100.00, rules)

puts "Original Price: $#{result.original_price}"
puts "Final Price: $#{result.final_price}"
puts "Total Savings: $#{result.total_savings} (#{result.savings_percentage}%)"
puts "\nBreakdown:"
puts result.breakdown
```

**Output:**
```
Original Price: $100.0
Final Price: $76.5
Total Savings: $23.5 (23.5%)

Breakdown:
1. Holiday Special - Fixed Discount: amount: 10.0
2. Summer Sale - Percentage Discount: percentage: 15.0, discount_amount: 13.5
```

### Using Metadata for Context

```ruby
# Pass additional context via metadata
context = PriceContext.new(100.00, {
  quantity: 5,
  loyalty_points: 500
})

result = Calculator.calculate(context, rules)
# => Applies quantity-based and loyalty point rules
```

## Design Patterns

This project demonstrates several design patterns:

1. **Single Table Inheritance**: Core Rails STI implementation
2. **Template Method Pattern**: `apply()` delegates to `transform()`
3. **Strategy Pattern**: Each rule type implements different behavior
4. **Service Object**: `Calculator` orchestrates rule application
5. **Data Transfer Object**: `PriceContext` carries data through calculations

## Advantages of STI in This Context

1. **Simplicity**: Single table, no complex JOINs
2. **Shared Attributes**: All rules share `name`, `active`, `priority`, `starts_at`, `ends_at`
3. **Polymorphism**: Uniform interface (`apply`) with diverse implementations
4. **Extensibility**: Add new rule types without schema changes
5. **Performance**: Efficient querying by priority and date ranges

## When to Use STI

STI works well when:
- Subclasses share most attributes
- Objects are used similarly
- You rarely query only one type
- Type-specific attributes are minimal

For this pricing engine, all rules share activation logic, scheduling, and priority—making STI ideal.

## Requirements

- Ruby 3.x
- Rails 8.1.0.rc1
- SQLite3

## Setup

```bash
# Install dependencies
bundle install

# Setup database
rails db:create
rails db:migrate

# Optional: Load sample data
rails db:seed

# Run tests
rails test
```

## Adding a New Rule Type

1. Create a new model inheriting from `Rule`:

```ruby
# app/models/tiered_discount_rule.rb
class TieredDiscountRule < Rule
  attribute :properties, :json, default: -> {
    {'tiers' => []}
  }

  protected

  def transform(context)
    # Implement tier-based discount logic
    # ...
    context
  end
end
```

2. That's it! No migration needed—the rule is automatically stored in the `rules` table.

## Key Takeaways

- **STI uses a `type` column** to store the subclass name
- **One table, multiple classes** provides simplicity and performance
- **Rails handles everything** automatically through `ActiveRecord`
- **JSON properties column** provides flexibility for type-specific data
- **Template method pattern** ensures consistent interfaces

## License

This project is open source and available for educational purposes.
