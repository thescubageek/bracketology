# NCAA Basketball Tournament team
class Team
  attr_reader :name, :rank

  # Creates a new team
  #
  # @param name [String] team name
  # @param rank [Integer] team rank
  def initialize(name, rank)
    @name = name
    @rank = rank
  end

  # @return [String] formatted rank and name of team
  def to_s
    "##{rank} #{name}"
  end
end
