Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do 
    namespace :v1 do
      post '/employees/signup' => 'employees#create'
      post '/employees/login' => 'employees#login'
      get '/employees/gettoken' => 'employees#login_token'
      get '/employees' => 'employees#index'
      patch '/employees/changeactivestatus/:id' => 'employees#change_active_status'
      get '/employees/getreport/:id' => 'employees#generate_expenditure_report'
      # get '/employees/searchemployee/:subname' => 'employees#search_employee'
      get '/expenditures/getactive' => 'expenditures#abc'

      resources :expenditures
      patch 'expenditures/changeexpense/:id' => 'expenditures#change_expense_status'


      resources :comments, only: [:create]

    end
  end
end
