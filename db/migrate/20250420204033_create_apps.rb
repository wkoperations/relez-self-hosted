class CreateApps < ActiveRecord::Migration[7.1]
  def change
    create_table :apps do |t|
      t.string :name, null: false
      t.boolean :system, default: false, null: false
      t.string :image, null: false

      t.timestamps
    end

    add_index :apps, :name, unique: true
  end
end
