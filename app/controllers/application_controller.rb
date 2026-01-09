class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  
  private
  
  def record_not_found
    redirect_to root_path, alert: "データが見つかりません。新しいセットを開始してください。"
  end
end
