class AddZipToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :zipcode, :string
  end
end
