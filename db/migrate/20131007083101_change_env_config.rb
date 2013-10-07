class ChangeEnvConfig < ActiveRecord::Migration
  def up
    change_column :env_configs, :value, :text
  end

  def down
    change_column :env_configs, :value, :string
    
  end
end
