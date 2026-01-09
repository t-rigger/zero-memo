class MemoSet < ApplicationRecord
  belongs_to :user, optional: true
  has_many :memos, -> { order(:position) }, dependent: :destroy
  
  enum status: { in_progress: 0, completed: 1 }
  
  after_create :generate_memos
  
  def first_title
    memos.first&.title.presence || "untitled"
  end
  
  def pdf_filename
    date_str = (completed_at || created_at).strftime("%Y%m%d")
    sanitized_title = first_title.gsub(/[^\p{L}\p{N}_-]/, "_")[0..30]
    "#{date_str}_#{sanitized_title}.pdf"
  end
  
  private
  
  def generate_memos
    10.times { |i| memos.create!(position: i + 1) }
  end
end
