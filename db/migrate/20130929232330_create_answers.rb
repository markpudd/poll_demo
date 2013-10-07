class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.string :answer_text
      t.references :poll

      t.timestamps
    end
    add_index :answers, :poll_id
  end
end
