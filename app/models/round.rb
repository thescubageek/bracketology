# Round of the NCAA Basketball Tournament
class Round
  attr_accessor :games
  attr_reader :winners, :round_num, :name,
              :rule_points, :rule_operator, :points, :probability

  # Creates a new round
  #
  # @param games [Array<Game>] games in the round
  # @param round_num [Integer] round number
  # @param name [String] round name
  def initialize(games, round_num, name, rule_points, rule_operator)
    @games = games
    @name = name
    @round_num = round_num
    @rule_points = rule_points
    @rule_operator = rule_operator
    @points = 0
    @probability = 0.0
    @winners = []
  end

  # Plays a simulation of the round
  #
  # @return [Array<Hash>] round winners
  def play
    puts "\n\n***\n\nSimulating #{name}...\n"
    @winners = @games.map { |game| game.play }

    puts "\n\n*** #{name} winners:"
    @winners = @games.map do |game|
      winner = game.play

      @points += game.points
      @probability += game.probability

      puts "#{winner} wins for #{game.points} points (#{game.format_probability})"
      winner
    end

    @probability = @games.count > 0 ? @probability / @games.count : 0.0

    puts "\nMax points: #{@points} (#{(100.0 * @probability).round(4)}%)"

    @winners
  end
end
