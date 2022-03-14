# NCAA Basketball Tournament game simulator
class Game
  attr_reader :home_team, :away_team, :winner,
              :rule_points, :rule_operator,
              :points, :probability

  # Creates a new game
  #
  # @param home_team [Team] home team in the matchup
  # @param away_team [Team] away team in the matchup
  # @param rule_points [Integer] number of points awarded to winner
  # @param rule_operator [String] '+' or '*'
  def initialize(home_team, away_team, rule_points, rule_operator)
    @home_team = home_team
    @away_team = away_team
    @rule_points = rule_points
    @rule_operator = rule_operator
    @winner = nil
    @points = 0
    @probability = 0.0
  end

  # Simulates a game based on the rankings of the two teams in the matchup
  #
  # @note The simulation is based on a simple weighted coin flip. Each team is assigned
  #   the inverse ratio of the other team's ranking and a random number between 0.0 and 1.0
  #   is determined. If the number lies within the home team's odds then the home team wins,
  #   otherwise the away team wins
  # @example If a team ranked #1 plays a team ranked #7 then the odds of home team winning are
  #   (7.0 / 8.0) == 0.875 and the odds of away team winning are (1.0 / 8.0) == 0.125. If the
  #   random number is <= 0.875 then home team wins.
  #
  # @return [Team] winning team
  def simulate
    SecureRandom.rand(1.0) <= home_team_odds ? home_team : away_team
  end

  # Simulates playing the game and assigns the winner
  #
  # @return [Hash] hash containing winning Team, probabilty of winner (float 0.0 < n < 1.0),
  #   and points award to the winner based on round
  def play
    set_winner(simulate)
  end

  # @return [Float] probability of winner winning
  def get_probability
    @winner == @home_team ? home_team_odds : 1 - home_team_odds
  end

  # @return [Integer] number of points awarded for choosing the winner
  def get_points
    @winner.rank.send(@rule_operator, @rule_points)
  end

  # Sets the winner of the Game and updates probability/points
  #
  # @param winning_team [Team] winning team
  # @return [Team] winning team
  def set_winner(winning_team)
    @winner = winning_team
    @probability = get_probability
    @points = get_points
    @winner
  end

  # Calculates the home team odds which are the inverse of the away team's rank ratio
  #
  # @return [Float] odds of home team winning in range of 0.0 <= n <= 1.0
  def home_team_odds
    away_team.rank.to_f / (home_team.rank.to_f + away_team.rank.to_f)
  end

  def home_team_won?
    @winner == @home_team
  end

  def format_probability
    "#{(100.0 * probability).round(4)}%"
  end
end
