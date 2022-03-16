# Round of the NCAA Basketball Tournament
class Round
  attr_accessor :games
  attr_reader :winners, :name

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
    @winners = []
  end

  # Plays a simulation of the round
  #
  # @return [Array<Hash>] round winners
  def play
    puts "\n\n***\n\nSimulating #{name}...\n"
    @winners = @games.map do |game|
      game.play
    end

    puts "\n\n*** #{name} winners:"
    @winners.each do |winner|
      "#{winner[:winner]} wins for #{winner[:points]} points (#{(100*probability).round(4)}%)"
    end
    @winners
  end
end
