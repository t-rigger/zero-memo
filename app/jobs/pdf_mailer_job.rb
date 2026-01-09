class PdfMailerJob < ApplicationJob
  queue_as :default
  
  def perform(memo_set_id)
    memo_set = MemoSet.find(memo_set_id)
    
    # メールアドレスがない場合はスキップ
    return unless memo_set.recipient_email.present?
    
    pdf_data = PdfGenerationService.new(memo_set).generate
    
    MemoMailer.send_pdf(
      email: memo_set.recipient_email,
      pdf_data: pdf_data,
      filename: memo_set.pdf_filename
    ).deliver_now
    
    # 送信後はメールアドレスを削除（プライバシー保護）
    memo_set.update!(recipient_email: nil)
  end
end
