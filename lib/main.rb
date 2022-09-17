require "json"

class Game

    attr_reader :amount_of_mistakes, :used_letters, :random_word, :answer

    def initialize()
        @amount_of_mistakes = 0
        @used_letters = []
        @random_word = ""
        @random_word = File.readlines("google-10000-english-usa-no-swears.txt")[rand(0..987)].chomp until 4 < @random_word.length && @random_word.length < 13 
        @answer = Array.new(@random_word.length, "*")
        @player_input = ""
        @round = 0
    end

    def get_input
        if @round == 0 
            print "  Load game or make your guess: "
            @player_input = gets.chomp.downcase
        else
            print "  Enter your guess: "
            @player_input = gets.chomp.downcase
        end
        if @player_input == "save" || @player_input == "load"
            return
        end
        until @player_input.length == 1 && ('a'..'z').any? { |l| l == @player_input} && !(@used_letters.any? { |l| l == @player_input}) 
            print "  Enter a new one: "
            @player_input = gets.chomp.downcase
            if @player_input == "save"
                return
            end
        end
        @used_letters.push(@player_input)
        puts ""
    end

    def check_input
        matching = false
        @random_word.split("").each_with_index do |l, i|
            if l == @player_input
                @answer[i] = @player_input
                matching = true
            end
        end
        if matching == false 
            @amount_of_mistakes += 1
        end 
        matching = false
    end

    def to_json
        {
            "amount_of_mistakes" => @amount_of_mistakes,
            "used_letters" => @used_letters,
            "random_word" => @random_word,
            "answer" => @answer
        }.to_s.gsub("=>", ": ")
    end

    def save_game
        File.open("saved_game.json", "w") { |f| f.puts self.to_json }
    end

    def load_game
        data = File.open("saved_game.json", "r") { |f| f.gets }
        @amount_of_mistakes = JSON.parse(data)["amount_of_mistakes"]
        @used_letters = JSON.parse(data)["used_letters"]
        @random_word = JSON.parse(data)["random_word"]
        @answer = JSON.parse(data)["answer"]
    end

    def play
        Board.new(self).board
        self.get_input
        @round += 1
        if @player_input == "save"
            self.save_game
            Board.new(self).board
            puts ""
            puts "  Game saved!"
            puts ""
            return
        end
        if @player_input == "load"
            self.load_game
            Board.new(self).board
            puts ""
            puts "  Game loaded!"
            puts ""
            self.play
        end
        self.check_input
        if @amount_of_mistakes == 7
            Board.new(self).board
            puts ""
            puts "  You lost!"
            puts ""
            return
        end
        if @answer.join == @random_word
            Board.new(self).board
            puts ""
            puts "  You won!"
            puts ""
            return
        end
        self.play
    end

end

class Board

    @@parts = { r: "|", h: "O", ra: "\\", la: "/", b: "|", rl: "/", ll: "\\" }

    def initialize(game)
        @game = game
    end

    def board
        puts "  This is Hang Man"
        puts "  Every round you should enter a letter."
        puts "  The answer only contains letter that are found"
        puts "  in the english alphabet."
        puts "  If you type 'save' you can save the game."
        puts "  If you type 'load' you can load in your last save."
        puts ""
        puts "  _________"
        puts "  |       #{@@parts[:r] if @game.amount_of_mistakes >= 1}"
        puts "  |      #{@@parts[:ra] if @game.amount_of_mistakes >= 3}#{@@parts[:h] if @game.amount_of_mistakes >= 2}#{@@parts[:la] if @game.amount_of_mistakes >= 4}"
        puts "  |       #{@@parts[:b] if @game.amount_of_mistakes >= 5}"
        puts "  |      #{@@parts[:rl] if @game.amount_of_mistakes >= 6} #{@@parts[:ll] if @game.amount_of_mistakes >= 7} "
        puts "  |"
        puts ""
        puts "  Used letters: #{@game.used_letters.join(", ")}"
        puts ""
        puts "  Secret word: #{@game.answer.join}"

    end
end

Game.new.play

