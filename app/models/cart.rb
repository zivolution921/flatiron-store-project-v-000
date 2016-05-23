class Cart < ActiveRecord::Base
  belongs_to :user
  has_one :order
  has_many :line_items
  has_many :items, through: :line_items

  def add_item(item_id)
    item = Item.find(item_id)
    lineitem = line_items.detect {|v| v.item == item}
    lineitem ||= LineItem.new
    lineitem.cart = self
    lineitem.item = item 
    lineitem
  end

  def total
    total = 0
    self.line_items.each do |line_item|
      item = Item.find(line_item.item_id)
      total += (item.price * line_item.quantity)
    end
    total
  end


  def checkout
    self.line_items.each do |line_item|
      item = Item.find(line_item.item_id)
      item.inventory -= line_item.quantity
      item.save
    end
    self.status = "submitted"
    order = self.build_order
    order.user = self.user
    self.save
  end
end