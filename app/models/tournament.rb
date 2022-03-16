# frozen_string_literal: true

# NCAA Basketball Tournament simulator
class Tournament
  IMPORT_TOURNAMENT_PATH = Rails.root.join('brackets', 'import').freeze
  DEFAULT_IMPORT_FILE = 'ncaa_2022.json'
  EXPORT_TOURNAMENT_PATH = Rails.root.join('brackets', 'export').freeze
  RESULTS_TOURNAMENT_PATH = Rails.root.join('brackets', 'results').freeze

  ROUND_NAMES = [
    'First Round',
    'Second Round',
    'Sweet Sixteen',
    'Elite Eight',
    'Final Four',
    'Championship'
  ].freeze

  RULE_BONUSES = [nil, '+', '-'].freeze
  RULES = {
    points: [1, 2, 4, 8, 16, 32],
    operator: '+'
  }.freeze

  attr_reader :year, :rounds, :first_four, :teams, :winner,
              :max_total_points, :probability

  class << self
    # Imports the tournament teams from a JSON file
    #
    # @param import_file [JSON] imported teams
    # @return [Hash<Array>] hash for first four and round of 64 teams
    def import(tourney_file)
      json = JSON.parse(File.read(tourney_file))
      # first_four = import_teams(json['first_four'])
      first_four = [] # disable first four for this year
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

    def calculate_final_results(num = nil, path = EXPORT_TOURNAMENT_PATH)
      files = Dir.glob("#{path}/*")
      num ||= files.count
      files = files.shuffle.take(num) if num != files.count

      results = {}
      files.each do |file|
        JSON.parse(File.read(file)).each do |round_name, winners|
          results[round_name] ||= []

          winners.each_with_index do |winner, idx|
            results[round_name][idx] ||= {}
            team = Team.new(winner['name'], winner['rank'])
            key = team.to_s
            results[round_name][idx][key] ||= { 'name' => team.name, 'rank' => team.rank, 'count' => 0 }
            results[round_name][idx][key]['count'] += 1
          end
        end
      end

      final_winners = results.reduce({}) do |hash, (round_name, games)|
        winners = games.map do |game_winners|
          game_winners.to_a.sort { |a, b| b[1]['count'] <=> a[1]['count'] }.first[1]
        end
        hash.merge!(round_name => winners)
      end

      version = DateTime.now.strftime('%Q')
      File.write("#{RESULTS_TOURNAMENT_PATH}/#{num}_#{version}.json", final_winners.to_json)
      final_winners
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
    @bonus_operator = RULES[:operator]
    @round_points = RULES[:points]
  end

  # Resets the rounds and winners variables
  def reset
    @first_four_winners = []
    @rounds = []
    @winner = nil
    @probabilities = []
    @points = 0
  end

  # Plays a simulation of the tournament
  #
  # @param should_export [Boolean] if true, export results of the simulation
  # @param sims [Integer] number of tournaments to simulate if exporting
  # @return [Team] championship winner
  def play(should_export = false, sims = 1)
    sims = 1 unless should_export

    sims.times do |_|
      reset
      simulate_first_four if first_four.present?

      @rounds.push(build_round(@teams))
      simulate while @winner.blank?

      puts "#{year} tournament winner: #{@winner}"
      export if should_export
      sleep 0.1 if sims > 1

      @max_total_points = calc_max_total_points
      @probability = calc_probability

      { winner: @winner, points: @max_total_points, probability: @probability }
    end
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
      if team.name == "ff_#{ff_index}"
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
    round_num = @rounds.count
    round_name ||= ROUND_NAMES[round_num]
    round = Round.new([], round_name)

    while i + 1 < round_teams.count
      round.games.push(Game.new(round_teams[i], round_teams[i + 1]))
      i += 2
    end
    round
  end

  # Calculate the max total points for a simluated tournament
  def calc_max_total_points
    @rounds.reduce(0) do |points, round|
      round.games.each do |game|
        points += game.winner[:points]
      end
    end
  end
  
  # Calculate the average probability of the bracket
  def calc_probability
    game_count = 0
    @rounds.reduce(0.0) do |prob, round|
      game_count += round.games.count
      round.games.each do |game|
        prob += game.winner[:probability]
      end
    end

    game_count > 0 ? prob / game_count : 0.0
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