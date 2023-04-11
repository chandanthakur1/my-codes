Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do 
    namespace :v1 do 
      resources :airlines, param: :slug
      resources :reviews
      get 'reviews/search/:airline_id' => 'reviews#search'
    end
  end

end
