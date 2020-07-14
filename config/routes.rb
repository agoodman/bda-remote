Rails.application.routes.draw do
  root to: 'welcome#index'

  # competitions are top level objects
  resources :competitions, only: [:create, :index, :show, :update] do
    member do
      get :generate
      get :start
    end
    resources :vessels, only: [:index, :new] do
      collection do
        post :batch
      end
    end
    resources :heats, only: [:index, :show] do
      member do 
        get :start
        get :stop
      end
      resources :vessels, only: :index, controller: 'heats/vessels'
      resources :records, only: :index
      post 'records/batch'
    end
  end

  # players are top level objects
  resources :players, only: [:create, :index, :show, :update]

  # rescue bad routes
  match '*unmatched', to: 'application#bad_request', via: :all
end
