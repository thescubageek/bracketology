class TournamentController < ApplicationController
  def index
    # file_path = params.permit(:file_path) || 
    # sims = params.permit(:sims)
    file = params.permit(:file)
    import_file = "#{Tourament::IMPORT_TOURNAMENT_PATH}/#{file}.json" if file.present?
    import_file ||= "#{Tournament::IMPORT_TOURNAMENT_PATH}/#{Tournament::DEFAULT_IMPORT_FILE}"

    if import_file.present?
      @tournament = Tournament.import(import_file)
      @tournament.play(params.permit(:export))
    end
  end
end
