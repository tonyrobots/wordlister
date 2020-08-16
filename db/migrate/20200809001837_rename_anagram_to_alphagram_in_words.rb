class RenameAnagramToAlphagramInWords < ActiveRecord::Migration[6.0]
  def change
    rename_column :words, :anagram, :alphagram
  end
end
