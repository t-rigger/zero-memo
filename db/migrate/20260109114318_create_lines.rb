class CreateLines < ActiveRecord::Migration[7.1]
  def change
    create_table :lines do |t|
      t.references :memo, null: false, foreign_key: true, index: true
      t.text :content, null: false
      t.integer :row_order, null: false # 1から始まる行番号
      t.timestamps
    end
    
    add_index :lines, [:memo_id, :row_order], unique: true
  end
end
