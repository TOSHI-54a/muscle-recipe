Rails.application.routes.draw do
  get "search/create"
  post "searches/optimized", to: "searches#optimized"
  devise_for :users, skip: [ :registrations ], controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  resources :users, only: %i[show new edit create update destroy]
  resources :searches, only: %i[new create index show destroy] do
    collection do
      get :saved
      get :favorites
    end
  end
  resources :chat_rooms, only: %i[index show create destroy] do
    resources :messages, only: [ :create ]
  end
  resources :search_recipes do
    resource :like, only: %i[create destroy]
  end
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # ActionCable WebSocketのエンドポイント
  mount ActionCable.server => "/cable"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  post "/recipes", to: "search#create"

  # Defines the root path route ("/")
  # root "posts#index"
  root "homes#top"
end
