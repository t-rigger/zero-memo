class Line < ApplicationRecord
  belongs_to :memo
  
  validates :content, presence: true
  validates :row_order, presence: true,
            uniqueness: { scope: :memo_id },
            numericality: { only_integer: true, greater_than: 0 }
  
  before_validation :set_row_order, on: :create
  
  private
  
  def set_row_order
    self.row_order ||= memo.lines.maximum(:row_order).to_i + 1
  end
end
