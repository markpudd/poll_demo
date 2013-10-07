class CreateEnvConfigs < ActiveRecord::Migration
  def change
    create_table :env_configs do |t|
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
