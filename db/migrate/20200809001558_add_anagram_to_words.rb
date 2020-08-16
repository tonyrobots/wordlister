class AddAnagramToWords < ActiveRecord::Migration[6.0]
  def change
    add_column :words, :anagram, :string
  end
end
