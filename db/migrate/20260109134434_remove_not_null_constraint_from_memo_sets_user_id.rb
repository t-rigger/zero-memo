class RemoveNotNullConstraintFromMemoSetsUserId < ActiveRecord::Migration[7.1]
  def change
    change_column_null :memo_sets, :user_id, true
  end
end
