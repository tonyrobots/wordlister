class AddSourceIdToWords < ActiveRecord::Migration[6.0]
  def change
    add_column :words, :source_id, :integer
  end
end
