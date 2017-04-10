class LongestWordController < ApplicationController

  def game
    @grid = []
    for i in 1..9 do
      @grid << (65 + rand(26)).chr
    end
    @grid = @grid.join(" ")
  end

  def score
    @grid = params[:grid]
    @answer = params[:shot]
    @time_taken = (Time.now - Time.at(params[:start_time].to_i)).round(2)
    @egal = get_translation(@answer)

    @grid_check = @grid.upcase
    @answer_check = @answer.upcase

    if included?(@answer_check.split(""), @grid_check.split(" ")) && !@egal.nil?
      @message = "Well done"
      @score = compute_score(@answer, @time_taken).round(2)
    else
      @message ="too much letters or not an english word"
      @score = 0
    end

  end


  def included?(guess, grid)
    guess.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def get_translation(word)
  api_key = "YOUR_SYSTRAN_API_KEY"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
    end
  end

end
