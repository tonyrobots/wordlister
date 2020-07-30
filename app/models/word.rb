class Word < ApplicationRecord
  # for search:
  include PgSearch
  pg_search_scope :search_by_word, against: [:word],
   using: {
    tsearch: {
      prefix: true
    }
  }

  belongs_to :source,  optional: true


  validates :word, presence: true, uniqueness: true
  default_scope { order(word: :asc) }

  before_validation :downcase_word

  def downcase_word
    self.word = word.downcase
  end
 
  def import import_file #not used
      File.foreach( import_file.path ).with_index do |line, index| 
    
        # Process each line.
    
        # For any errors just raise an error with a message like this: 
        #   raise "There is a duplicate in row #{index + 1}."
        # And your controller will redirect the user and show a flash message.
    
      end
    end
end
