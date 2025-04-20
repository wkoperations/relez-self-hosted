class AddPortMappingsToApps < ActiveRecord::Migration[8.0]
  def change
    # First add the column without constraints
    add_column :apps, :port_mappings, :json

    # Set default value for existing records
    reversible do |dir|
      dir.up do
        execute "UPDATE apps SET port_mappings = '[]' WHERE port_mappings IS NULL"
      end
    end

    # Now add the constraint
    change_column_null :apps, :port_mappings, false
  end
end
