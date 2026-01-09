class CreateMemoSets < ActiveRecord::Migration[7.1]
  def change
    create_table :memo_sets do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.integer :status, default: 0, null: false # enum: 0=in_progress, 1=completed
      t.datetime :completed_at
      t.timestamps
    end
    
    add_index :memo_sets, [:user_id, :status]
    add_index :memo_sets, :completed_at
  end
end
