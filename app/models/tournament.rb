# NCAA Basketball Tournament simulator
class Tournament
  IMPORT_TOURNAMENT_PATH = Rails.root.join('brackets', 'import').freeze
  DEFAULT_IMPORT_FILE = -'64_team_test.json'
  EXPORT_TOURNAMENT_PATH = Rails.root.join('brackets', 'export').freeze

  ROUND_NAMES = [
    'First Round',
    'Second Round',
    'Sweet Sixteen',
    'Elite Eight',
    'Final Four',
    'Championship'
  ].freeze

  attr_reader :year, :rounds, :first_four, :teams, :winner

  class << self
    # Imports the tournament teams from a JSON file
    #
    # @param import_file [JSON] imported teams
    # @return [Hash<Array>] hash for first four and round of 64 teams
    def import(tourney_file)
      json = JSON.parse(File.read(tourney_file))
      first_four = import_teams(json['first_four'])
      teams = import_teams(json['teams'])
      new(teams, first_four)
    end

    # Imports teams
    #
    # @param imported_teams [Array<Hash>] team imports with rank and name
    # @return [Array<Team>] array of new Teams
    def import_teams(imported_teams)
      imported_teams.map do |team|
        Team.new(team['name'], team['rank'])
      end
    end
  end

  # Creates a new tournament simulation
  #
  # @param teams [Array<Team>] array of round of 64 Teams
  # @param first_four [Array<Team>] array of firt four round of Teams
  # @param year [Year] (Time.current.year) tournament year
  def initialize(teams, first_four, year = Time.current.year)
    @year = year
    @first_four = first_four
    @teams = teams
  end

  # Resets the rounds and winners variables
  def reset
    @first_four_winners = []
    @rounds = []
    @winner = nil
  end

  # Plays a simulation of the tournament
  #
  # @param should_export [Boolean] if true, export results of the simulation
  # @return [Team] championship winner
  def play(should_export = false)
    reset

    simulate_first_four

    @rounds.push(build_round(@teams))
    simulate while @winner.blank?

    puts "#{year} tournament winner: #{@winner}"
    export if should_export

    winner
  end

  # Simulators the first four round of games and adds the winners to the
  #   round of 64 teams
  #
  # @return [Array<Team>] first four round winners
  def simulate_first_four
    ff_round = build_round(@first_four, 'First Four')
    @first_four_winners = ff_round.play

    ff_index = 0
    @teams.each_with_index do |team, idx|
      if team.rank == 16
        @teams[idx] = @first_four_winners[ff_index]
        ff_index += 1
      end
    end
    @first_four_winners
  end

  # Simulates the all rounds of the tournament to determine winners
  #
  # @return [Team] championship winner if no teams remain
  # @return [Array<Team>] round winners if teams remain
  def simulate
    round = @rounds.last
    winners = round.play
    if winners.count > 1
      next_round = build_round(winners)
      @rounds.push(next_round)
    else
      @winner = winners.first
    end
  end

  # Builds a round of game matchups for the teams
  #
  # @param round_teams [Array<Team>] teams playing in the round
  # @param round_name [String] name of round
  # @return [Round] tournament round
  def build_round(round_teams, round_name = nil)
    i = 0
    round_name ||= ROUND_NAMES[@rounds.count]
    round = Round.new([], round_name)

    while i + 1 < round_teams.count
      round.games.push(Game.new(round_teams[i], round_teams[i + 1]))
      i += 2
    end
    round
  end

  # Exports the winners to a JSON file
  #
  # @return [Hash] exported JSON hash
  def export
    export_json = { 'First Four Winners' => @first_four_winners }
    @rounds.each do |round|
      export_json["#{round.name} Winners"] = round.winners
    end

    export_file = "#{EXPORT_TOURNAMENT_PATH}/#{DateTime.now.strftime('%Q')}.json"
    File.write(export_file, export_json.to_json)
    export_json
  end
end