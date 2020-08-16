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

  before_validation :downcase_word, :set_alphagram

  def self.search_by_substring (query)
    query.downcase!
    Word.where(["word LIKE ?", "%#{query}%"])
  end

  def downcase_word
    self.word = word.downcase
  end

  def set_alphagram
    # alphagram used to efficently find anagrams
    self.alphagram = word.chars.sort.join
  end

  def anagrams
    Word.where(alphagram: self.alphagram)
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
