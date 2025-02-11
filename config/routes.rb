Rails.application.routes.draw do
  get "messages/create"
  get "search/create"
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  resources :users
  resources :searches, only: %i[new create index show] do
    collection do
      get :saved
    end
  end
  resources :chat_rooms, only: %i[index show create destroy] do
    resources :messages, only: [ :create ]
  end

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
