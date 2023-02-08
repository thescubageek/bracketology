require "rqrcode"

module TournamentHelper
  def render_qr_code(tourney_code)
    tourney_code = ActionController::Base.helpers.sanitize(tourney_code)
    "<img src='#{request.base_url}/qr/#{tourney_code}.svg' class='qr_svg qr_#{tourney_code}'>".html_safe
  end

  def render_bracket(bracket_num, teams)
    "<div class='bracket bracket_#{bracket_num}'>\n#{render_teams(teams)}\n</div>".html_safe
  end

  def render_empty_bracket(bracket_num, num_teams)
    empty_teams = num_teams.times.map { |_| '???' }
    render_bracket(bracket_num, empty_teams)
  end

  def render_teams(teams)
    Array.wrap(teams).each_with_index.map do |team, idx|
      "<div class='team pos_#{idx}'>#{team}</div>"
    end.join("\n")
  end
end
