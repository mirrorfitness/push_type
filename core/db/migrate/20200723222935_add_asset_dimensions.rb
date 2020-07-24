class AddAssetDimensions < ActiveRecord::Migration[5.2]
  def change
    add_column :push_type_assets, :file_width, :integer, default: 0, nullable: false
    add_column :push_type_assets, :file_height, :integer, default: 0, nullable: false
  end
end
