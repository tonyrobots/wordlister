namespace :import  do
    desc "Import words from URL"
    task :from_url, [:url] => [ :environment ] do |t, args|
        if args[:url] then url = args[:url]
        else
            url = "https://isitraining.in/portland"
        end
        
        puts url
        doc = Nokogiri::HTML(open(url))

        doc.css('script').remove
        page_text = doc.at('body').inner_text
        # puts page_text
        words = page_text.scan(/[a-z]{3,}/i) #find words with 3 or more letters
        words = words.map{|i| i.downcase}.uniq # just the unique ones (case insensitive)

        p words.length, words


    end


    desc "Import words from a text file (one word per line)"
    task :from_text_file, [:filename] => [ :environment ] do |t, args|
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        if args[:filename] then filename = args[:filename] 
        else filename = File.join(Rails.root, "lib", "wordlist.txt")
        end

        total=0
        errors=0
        saved=0
        dupes=0
        updated=0
        errormessage = ""

        trap "SIGINT" do
            puts "\nImport aborted, #{saved} words added out of #{total}"
            exit 130
        end
        

        if !File.file?(filename) then
            puts "Can't find the file #{filename}"
            abort
        end

        linecount = IO.readlines(filename).size

        puts "Importing #{filename} -- #{linecount} lines"
        
        # get the source id for the filename (note this is only pulled once at start of import, and
        # will break if the source_id for a given source is changed during or after import)
        source_id = get_source_id_by_name(File.basename(filename))

        file = File.open(filename, "r").each do |line|
            total+=1

            line.strip! #strip whitespace from ends
            line.scrub! # remove non-UTF8 chars
            line = line.gsub(/\s/,'')    # remove blank space, might be redundant but whatever

            # skip if empty line 
            if line.empty? then
                dupes +=1 
                next
            end
            
            show_progress_bar total, linecount

            begin # try to parse the entry

                if line.include? ";" then # is there a score included?
                    m = line.match(/(^.+);(\d+)?/)
                    word,score = m.captures
                else #no score, just parse the word and the db will assign default score
                    word = line
                end
                #puts "word: " + word + ", score: " + score

                #  cast to all lowercase or caps
                word.downcase!

                # strip special chars
                word.gsub!(/[^a-zA-Z]/,'')

                # skip short words
                if word.size < 3 then
                    dupes+=1 #  shorties count as dupes, close enough
                    next
                end

                # skip duplicates of existing words
                if Word.exists?(word: word) then
                    if  Word.find_by(word: word).score.nil? && score.present? #word exists but score isn't set
                        Word.find_by(word: word).update(score:score)
                        # errormessage += "set score for #{word} to #{score}\n"
                        updated +=1
                    else
                        dupes +=1
                    end
                    next
                elsif Word.create(word:word, score:score, source_id: source_id)
                    #puts "saved successfully"
                    saved+=1
                else
                    errors+=1
                    errormessage+= "* #{line}\n"
                end
            rescue => error
                errormessage+= "#{line},"
                errors +=1
                puts error.backtrace
            end


        end
        file.close
        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        time_elapsed = end_time - start_time
        report_to_console(total,saved,dupes,updated,errors,errormessage,time_elapsed)
    end

    def show_progress_bar (total, linecount)
        printf "\r #{total}/#{linecount} \t (%0.1f" % [(total.to_f/linecount) * 100] + "%%) complete."
    end

    def report_to_console (total, new_words, dupes, updated, errors, errormessage, time_elapsed)
        puts "\nImport completed in #{time_elapsed.round(2)} seconds. #{new_words} words added out of #{total}"
        puts "\n#{dupes} duplicates, short words, or blank lines skipped." if dupes>0
        puts "\n#{updated} scores updated." if updated>0
        puts "\n#{errors} errors." if errors>0
        puts "Messages:\n #{errormessage}" if !errormessage.empty?
    end

    def get_source_id_by_name (name)
        if my_source = Source.find_by(name:name)
            return my_source.id
        else 
            # create it
            my_source = Source.create(name:name)
            return my_source.id
        end
    end


end
