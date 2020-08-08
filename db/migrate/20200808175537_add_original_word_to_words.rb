class AddOriginalWordToWords < ActiveRecord::Migration[6.0]
  def change
    add_column :words, :original_word, :string
  end
end
