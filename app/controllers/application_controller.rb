class ApplicationController < ActionController::Base
  before_action :set_default_request_format

  def set_default_request_format
    request.format = :html unless params[:format]
  end
end
