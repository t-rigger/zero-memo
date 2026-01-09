class MemoSetCleanupJob < ApplicationJob
  queue_as :default
  
  def perform(memo_set_id)
    memo_set = MemoSet.find_by(id: memo_set_id)
    
    # 既に削除されている場合はスキップ
    return unless memo_set
    
    # MemoSetを削除（dependent: :destroy により関連するMemos, Linesも削除される）
    memo_set.destroy
    
    Rails.logger.info "[MemoSetCleanupJob] Deleted MemoSet ##{memo_set_id}"
  end
end
