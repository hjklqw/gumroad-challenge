class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.string :question, null: false, limit: 140
      t.text :context
      t.text :answer, limit: 1000
      t.integer :ask_count, null: false, default: 1

      t.timestamps
    end
  end
end
