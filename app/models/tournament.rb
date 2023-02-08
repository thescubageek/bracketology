# NCAA Basketball Tournament simulator
class Tournament
  class InvalidCode < StandardError; end

  IMPORT_TOURNAMENT_PATH = Rails.root.join('brackets', 'import').freeze
  DEFAULT_IMPORT_FILE = -'ncaa_2021.json'
  EXPORT_TOURNAMENT_PATH = Rails.root.join('brackets', 'export').freeze
  RESULTS_TOURNAMENT_PATH = Rails.root.join('brackets', 'results').freeze

  CODE_LENGTH = 13
  TOTAL_GAMES = 63
  TOTAL_GAMES_WITH_FIRST_FOUR = 67

  ROUND_NAMES = [
    'First Round',
    'Second Round',
    'Sweet Sixteen',
    'Elite Eight',
    'Final Four',
    'Championship'
  ].freeze

  attr_reader :year, :rounds, :first_four, :teams, :winner, :code

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

    # Calculates the final results by randomly aggregating the results of
    #   previously saved simulations. The larger the value of `num` the more
    #   likely the results will contain fewer upsets
    #
    # @param num [Integer, nil] number of simulations to run
    # @param path [String] path for export file
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
            results[round_name][idx][key] ||= {
              'name'  => team.name,
              'rank'  => team.rank,
              'count' => 0
            }
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

    # Converts tournament code to binary code
    #
    # @param tourney_code [String] tournament code
    # @return [String] binary code
    def convert_tourney_code_to_binary_code(tourney_code)
      binary_code = tourney_code.gsub('-', '').to_i(36).to_s(2)
      binary_code.prepend('0') while binary_code.size < TOTAL_GAMES
      binary_code
    end

    # Converts tournament code to binary code
    #
    # @param binary_code [String] binary code representing Tournament results
    # @return [String] binary code
    def convert_binary_code_to_tourney_code(binary_code)
      tourney_code = binary_code.to_i(2).to_s(36)
      tourney_code.insert(1, '-') while tourney_code.length < CODE_LENGTH
      tourney_code
    end

    # Enter a phrase and generate a tournament bracket! Fun for everyone!
    #
    # @param phrase [String] phraises like "march madness" and "boo-yah",
    #   whatever you want creates a unique tournament
    def create_tourney_code_from_phrase(phrase)
      # Create hex hash based on string
      hash = OpenSSL::Digest::SHA256.hexdigest(phrase)
      binary_code = hash.to_i(16).to_s(2)[0...63]
      convert_binary_code_to_tourney_code(binary_code)
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
    @code = nil
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
      simulate_first_four

      @rounds.push(build_round(@teams))
      simulate while @winner.blank?
      @code = to_tourney_code

      puts "#{year} tournament winner: #{@winner}"
      puts "Code: #{@code}"
      export if should_export
      sleep 0.1 if sims > 1

      winner
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

  # @return [Integer] total number of games based on whether or not to include First Four
  def total_games
    @total_games ||= @first_four ? TOTAL_GAMES_WITH_FIRST_FOUR : TOTAL_GAMES
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

    export_file = "#{EXPORT_TOURNAMENT_PATH}/#{@code}.json"
    File.write(export_file, export_json.to_json)
    export_json
  end

  # Converts the Tournament results into a code that can be used to look it up later
  #
  # @return [String] tournament code
  def to_tourney_code
    self.class.convert_binary_code_to_tourney_code(to_binary_code)
  end

  # Transforms the results to a binary code string, where '0' represents a home team
  #   victory and '1' represents an away team victory
  def to_binary_code
    @rounds.reduce('') do |str, round|
      round.games.each do |game|
        str << (game.winner == game.home_team ? '0' : '1')
      end
      str
    end
  end

  # Loads a Tournament bracket from a tournament cody
  #
  # @param tourney_code [String] tournament code
  # @return [Tournament] completed tournament brackets
  def load_from_tourney_code(tourney_code)
    raise InvalidCode unless tourney_code.length == CODE_LENGTH

    reset

    @code = tourney_code
    binary_code = self.class.convert_tourney_code_to_binary_code(tourney_code)
    load_from_binary_code(binary_code)
  end

  # Parses a binary code string and loads it into a completed tournament
  #
  # @param binary_code [String] binary code representing Tournament results
  # @return [Tournament] completed tournament brackets
  def load_from_binary_code(binary_code)
    @rounds.push(build_round(@teams))

    while @winner.blank?
      round = @rounds.last
      round.winners = []

      round.games.each do |game|
        bit = binary_code.slice!(0)
        winner = bit == '0' ? game.home_team : game.away_team
        game.winner = winner
        round.winners << winner
      end

      if round.winners.count > 1
        next_round = build_round(round.winners)
        @rounds.push(next_round)
      else
        @winner = round.winners.first
      end
    end
  end
end
