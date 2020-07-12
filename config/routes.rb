Rails.application.routes.draw do
  namespace :heats do
    get 'vessels/index'
  end
  root to: 'welcome#index'

  get 'welcome/index'
  
  # players are top level objects
  resources :players, only: [:create, :index, :show, :update]
  
  # competitions are top level objects
  resources :competitions, only: [:create, :index, :show, :update] do
    member do
      get :generate
      get :start
    end
    resources :vessels, only: [:index, :create, :update]
    resources :heats, only: [:index, :show] do
      member do 
        get :start
        get :finish
      end
      resources :vessels, only: :index, controller: 'heats/vessels'
      post 'records/batch'
    end
  end
end
