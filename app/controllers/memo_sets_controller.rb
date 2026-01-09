class MemoSetsController < ApplicationController
  before_action :set_memo_set, only: [:show, :complete, :download, :send_email]
  
  def create
    # 前回のMemoSetがあれば削除
    if session[:memo_set_id].present?
      old_memo_set = MemoSet.find_by(id: session[:memo_set_id])
      old_memo_set&.destroy
    end
    
    @memo_set = MemoSet.create!
    session[:memo_set_id] = @memo_set.id
    redirect_to memo_path(@memo_set.memos.first)
  end
  
  def show
  end
  
  def complete
    @memo_set.update!(status: :completed, completed_at: Time.current)
    
    # 15分後に自動削除
    MemoSetCleanupJob.set(wait: 15.minutes).perform_later(@memo_set.id)
  end
  
  def download
    pdf_service = PdfGenerationService.new(@memo_set)
    
    send_data pdf_service.generate,
              filename: @memo_set.pdf_filename,
              type: "application/pdf",
              disposition: "attachment"
  end
  
  def send_email
    email = params[:email]
    
    if email.present? && email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
      @memo_set.update!(recipient_email: email)
      PdfMailerJob.perform_later(@memo_set.id)
      redirect_to root_path, notice: "PDFをメールで送信しました！"
    else
      redirect_to complete_memo_set_path(@memo_set), alert: "有効なメールアドレスを入力してください"
    end
  end
  
  private
  
  def set_memo_set
    @memo_set = MemoSet.find(params[:id])
    
    # セッションにあるIDと一致しない場合はアクセス拒否
    if session[:memo_set_id] != @memo_set.id
      redirect_to root_path, alert: "この操作を行う権限がありません"
    end
  end
end
