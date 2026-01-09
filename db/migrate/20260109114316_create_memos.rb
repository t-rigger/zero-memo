class CreateMemos < ActiveRecord::Migration[7.1]
  def change
    create_table :memos do |t|
      t.references :memo_set, null: false, foreign_key: true, index: true
      t.string :title, limit: 100, default: "", null: false
      t.integer :position, null: false # 1..10
      t.timestamps
    end
    
    add_index :memos, [:memo_set_id, :position], unique: true
  end
end
