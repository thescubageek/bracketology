Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "tournament#index"

  get '/c/:code', to: "tournament#show"
  get '/qr/:code', to: "tournament#qr_code"

  get '/phrase', to: "tournament#enter_phrase"
  get '/submit_phrase', to: "tournament#submit_phrase"
end
