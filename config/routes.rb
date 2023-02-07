Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "tournament#index"

  get '/:code', to: "tournament#show"
  get '/qr/:code', to: "tournament#qr_code"
end
