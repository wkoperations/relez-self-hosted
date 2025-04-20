class AddTypeToAppConfigs < ActiveRecord::Migration[8.0]
  def change
    add_column :app_configs, :value_type, :string
  end
end
