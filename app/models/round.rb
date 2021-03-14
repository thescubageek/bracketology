# Round of the NCAA Basketball Tournament
class Round
  attr_accessor :games
  attr_reader :winners, :name

  # Creates a new round
  #
  # @param games [Array<Game>] games in the round
  # @param name [String] round name
  def initialize(games, name)
    @games = games
    @name = name
    @winners = []
  end

  # Plays a simulation of the round
  #
  # @return [Array<Team>] round winners
  def play
    puts "\n\n***\n\nSimulating #{name}...\n"
    @winners = @games.map do |game|
      game.play
      game.winner
    end
    puts "\n\n*** #{name} winners: \n#{@winners.join("\n")}\n"
    @winners
  end
end
