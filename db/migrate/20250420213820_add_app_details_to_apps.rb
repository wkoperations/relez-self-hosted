class AddAppDetailsToApps < ActiveRecord::Migration[8.0]
  def change
    # First add the columns without constraints
    add_column :apps, :description, :string
    add_column :apps, :restart_policy, :string
    add_column :apps, :rolling_update, :boolean
    add_column :apps, :health_check_path, :string
    add_column :apps, :port, :integer

    # Set default values for existing records
    reversible do |dir|
      dir.up do
        execute "UPDATE apps SET description = 'No description provided' WHERE description IS NULL"
        execute "UPDATE apps SET restart_policy = 'unless-stopped' WHERE restart_policy IS NULL"
        execute "UPDATE apps SET rolling_update = false WHERE rolling_update IS NULL"
        execute "UPDATE apps SET health_check_path = '/' WHERE health_check_path IS NULL"
        execute "UPDATE apps SET port = 3000 WHERE port IS NULL"
      end
    end

    # Now add the constraints
    change_column_null :apps, :description, false
    change_column_null :apps, :restart_policy, false
    change_column_null :apps, :rolling_update, false
    change_column_null :apps, :health_check_path, false
    change_column_null :apps, :port, false

    add_index :apps, :restart_policy
  end
end
