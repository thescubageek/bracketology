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
    @winners = @games.map { |game| add_winner(game, game.play) }
    @probability = calc_probability
    @winners
  end

  # Sets the winner of a Game in the Round and updates probability/points
  #
  # @param game [Game] game in round
  # @param winning_team [Team] winning team
  # @return [Team] winning team
  def add_winner(game, winning_team)
    game.set_winner(winning_team)
    @points += game.points
    @probability += game.probability

    @winners << winning_team
    winning_team
  end

  # @return [Float] probability of round happening
  def calc_probability
    @games.count > 0 ? @probability / @games.count : 0.0
  end

  # Sets winners only if is not already set
  #
  # @param winners_array [Array<Team>] winners
  def winners=(winners_array)
    @winners = winners_array if @winners.blank?
  end
end
