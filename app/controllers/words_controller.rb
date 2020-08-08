class WordsController < ApplicationController
  include Pagy::Backend
  before_action :set_word, only: [:show, :edit, :update, :destroy]

  # GET /words
  # GET /words.json
  def index
    if params[:term]
      # first strip spaces or hyphens
      @term = params[:term].gsub(/[^a-zA-Z]/,'')
      @header = "Words that contain '#{@term}''"
      @pagy, @words = pagy(Word.search_by_substring(@term), items:20)
      @count = @pagy.count
    else
      @header = "Words"
      @pagy, @words = pagy(Word.all, items:250)
      @count = Word.count
    end
  end

  # GET /words/1
  # GET /words/1.json
  def show
  end

  # GET /words/new
  def new
    @word = Word.new
  end

  # GET /words/1/edit
  def edit
  end

  # POST /words
  # POST /words.json
  def create
    @word = Word.new(word_params)

    respond_to do |format|
      if @word.save
        format.html { redirect_to @word, notice: 'Word was successfully created.' }
        format.json { render :show, status: :created, location: @word }
      else
        format.html { render :new }
        format.json { render json: @word.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /words/1
  # PATCH/PUT /words/1.json
  def update
    respond_to do |format|
      if @word.update(word_params)
        format.html { redirect_to @word, notice: 'Word was successfully updated.' }
        format.json { render :show, status: :ok, location: @word }
      else
        format.html { render :edit }
        format.json { render json: @word.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /words/1
  # DELETE /words/1.json
  def destroy
    @word.destroy
    respond_to do |format|
      format.html { redirect_to words_url, notice: 'Word was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def new_import
    #@words = Word.all
  end
  
  def import
    begin
      Word.import( params[:words][:import_file] ) 
  
      flash[:success] = "<strong>Words Imported!</strong>"
  
      redirect_to words_path
  
    rescue => exception 
      flash[:error] = "There was a problem importing that file.<br>
        <strong>#{exception.message}</strong><br>"
  
      redirect_to import_new_words_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_word
      @word = Word.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def word_params
      params.require(:word).permit(:word, :score)
    end
end
