class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :answer
      t.references :player

      t.timestamps
    end
    add_index :votes, :answer_id
    add_index :votes, :player_id
  end
end
