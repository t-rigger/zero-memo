class AddRecipientEmailToMemoSets < ActiveRecord::Migration[7.1]
  def change
    add_column :memo_sets, :recipient_email, :string
  end
end
