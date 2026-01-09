class Memo < ApplicationRecord
  belongs_to :memo_set
  has_many :lines, -> { order(:row_order) }, dependent: :destroy
  
  validates :position, presence: true, 
            uniqueness: { scope: :memo_set_id },
            inclusion: { in: 1..10 }
  validates :title, length: { maximum: 100 }
  
  def next_memo
    memo_set.memos.find_by(position: position + 1)
  end
  
  def is_last?
    position == 10
  end
end
