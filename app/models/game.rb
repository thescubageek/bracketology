# NCAA Basketball Tournament game simulator
class Game
  attr_reader :home_team, :away_team, :winner

  # Creates a new game
  #
  # @param home_team [Team] home team in the matchup
  # @param away_team [Team] away team in the matchup
  def initialize(home_team, away_team)
    @home_team = home_team
    @away_team = away_team
    @winner = nil
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
  # @return [Team] game winner
  def play
    @winner = simulate
  end

  # Calculates the home team odds which are the inverse of the away team's rank ratio
  #
  # @return [Float] odds of home team winning in range of 0.0 <= n <= 1.0
  def home_team_odds
    away_team.rank.to_f / (home_team.rank.to_f + away_team.rank.to_f)
  end
end