class LinesController < ApplicationController
  before_action :set_memo
  before_action :authorize_memo_access!
  
  def create
    @line = @memo.lines.build(line_params)
    
    if @line.save
      render json: { 
        status: "saved", 
        line_id: @line.id,
        row_order: @line.row_order
      }, status: :created
    else
      render json: { 
        status: "error", 
        errors: @line.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_memo
    @memo = Memo.find(params[:memo_id])
  end
  
  def authorize_memo_access!
    unless session[:memo_set_id] == @memo.memo_set_id
      render json: { status: "unauthorized" }, status: :forbidden
    end
  end
  
  def line_params
    params.require(:line).permit(:content, :row_order)
  end
end
