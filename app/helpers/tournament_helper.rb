module TournamentHelper
  def render_bracket(bracket_num, teams)
    "<div class='bracket bracket_#{bracket_num}'>\n#{render_teams(teams)}\n</div>".html_safe
  end

  def render_teams(teams)
    Array.wrap(teams).each_with_index.map do |team, idx|
      "<div class='team pos_#{idx}'>#{team}</div>"
    end.join("\n")
  end
end
