class TournamentController < ApplicationController
  before_action :load_import_file

  def index
    @tournament.play(params.permit(:export))
  end

  def show
    tourney_code = params.require(:code)
    @tournament.load_from_tourney_code(tourney_code)
    render template: 'tournament/index'
  rescue Tournament::InvalidCode => _e
    render :unprocessable_entity, format: :json, data: { message: 'invalid code' }
  end

  private

  def load_import_file
    file = params.permit(:file)
    @import_file = "#{Tournament::IMPORT_TOURNAMENT_PATH}/#{file}.json" if file.present?
    @import_file ||= "#{Tournament::IMPORT_TOURNAMENT_PATH}/#{Tournament::DEFAULT_IMPORT_FILE}"

    if @import_file.blank? || !File.exist?(@import_file)
      render :unprocessable_entity, format: :json, data: { message: 'invalid file name' }
      return
    end

    # read and parse file for errors
    JSON.parse(File.read(@import_file))
    @tournament = Tournament.import(@import_file)
  rescue JSON::ParserError => _e
    render :unprocessable_entity, format: :json, data: { message: 'invalid file format' }
  end
end
