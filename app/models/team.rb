# NCAA Basketball Tournament team
class Team
  attr_reader :name, :rank, :color

  # Creates a new team
  #
  # @param name [String] team name
  # @param rank [Integer] team rank
  # @param color [String] team color (plain text or hex)
  def initialize(name, rank, color = nil)
    @name = name
    @rank = rank
    @color = color || "##{SecureRandom.hex(3)}"
  end

  # @return [String] formatted rank and name of team
  def to_s
    "##{rank} #{name}"
  end
end
