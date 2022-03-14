class TournamentController < ApplicationController
  before_action :load_import_file, except: %i[qr_code]
  before_action :identify_tourney_code!, only: %i[show qr_code]

  def index
    @tournament.play(params.permit(:export))
  end

  def show
    @tournament.load_from_tourney_code(@tourney_code)
    render template: 'tournament/index'
  rescue Tournament::InvalidCode => _e
    render :unprocessable_entity, format: :json, data: { message: 'invalid code' }
  end

  def qr_code
    qrcode = ::RQRCode::QRCode.new("#{request.base_url}/#{@tourney_code}")

    svg = qrcode.as_svg(
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 3,
      standalone: true,
      use_path: true
    )

    render inline: svg, format: :svg
  end

  def enter_phrase
    render template: 'tournament/phrase'
  end

  def submit_phrase
    phrase = params.require(:phrase)
    @tourney_code = Tournament.create_tourney_code_from_phrase(phrase)
    redirect_to "/c/#{@tourney_code}"
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

  def identify_tourney_code!
    @tourney_code = params.require(:code)
    raise Tournament::InvalidCode unless @tourney_code.size == Tournament::CODE_LENGTH
  end
end
