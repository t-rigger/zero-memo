class MemoMailer < ApplicationMailer
  def send_pdf(email:, pdf_data:, filename:)
    attachments[filename] = pdf_data
    
    mail(
      to: email,
      subject: "【ZeroMemo】思考トレーニング完了 - #{filename}"
    )
  end
end
