class AddSfidToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :sfid, :string
  end
end
