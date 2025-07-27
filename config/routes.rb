Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      post "registration", to: "users#create"
      post "sessions", to: "sessions#create"
      get "users", to: "users#index"
      get "users/:id", to: "users#show"
      patch "users/:id", to: "users#update"
      delete "users/:id", to: "users#destroy"
    end
  end

  if Rails.env.test? || Rails.env.development?
    get "/test", to: "test#index"
    get "/test/not_found", to: "test#raise_not_found"
    get "/test/invalid_record", to: "test#raise_invalid_record"
    get "/test/error", to: "test#raise_standard_error"
  end
end
