class MemosController < ApplicationController
  before_action :set_memo
  before_action :authorize_memo_access!
  
  def show
    @lines = @memo.lines.order(:row_order)
  end
  
  def update
    if @memo.update(memo_params)
      if @memo.is_last?
        redirect_to complete_memo_set_path(@memo.memo_set), status: :see_other
      else
        redirect_to memo_path(@memo.next_memo), status: :see_other
      end
    else
      render :show, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_memo
    @memo = Memo.find(params[:id])
  end
  
  def authorize_memo_access!
    unless session[:memo_set_id] == @memo.memo_set_id
      redirect_to root_path, alert: "この操作を行う権限がありません"
    end
  end
  
  def memo_params
    params.require(:memo).permit(:title)
  end
end
