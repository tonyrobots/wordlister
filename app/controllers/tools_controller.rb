class ToolsController < ApplicationController
    include Pagy::Backend

    def substitution_test
        @str1, @str2 = params[:str1], params[:str2]
        @words = []
        @candidates = []

        return if !@str1 

        # Optimize a bit by starting with the rarer substring
        @candidates = Word.search_by_substring(@str1)
        @candidates2 = Word.search_by_substring(@str2)
        if @candidates2.count < @candidates.count
            @str1,@str2 = @str2,@str1
            @candidates = @candidates2
        end
        # <li><%= word.word %> -- <%= word.word.gsub(@str2, @str1) %> <br />    

        for candidate in @candidates
            test_word = candidate.word.gsub(@str1, @str2)
            if Word.exists?(word:test_word)
                new_word = Word.find_by_word(test_word)
                @words << [new_word, candidate]
            end
        end
    end

    


end
