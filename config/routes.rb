Rails.application.routes.draw do
  namespace :competitions do
    get 'organizers/index'
    get 'organizers/update'
    get 'organizers/create'
    get 'organizers/destroy'
  end
  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks"}

  get '/home' => 'welcome#index'

  get '/register' => 'welcome#register'
  get '/logout' => 'welcome#logout'
  get '/stats' => 'welcome#stats'
  get '/evaluate' => 'vessels#evaluate'
  post '/detail' => 'vessels#detail'

  # competitions are top level objects
  resources :competitions, only: [:new, :create, :index, :show, :edit, :update] do
    collection do
      get :template
      post :duplicate
    end
    member do
      get :generate
      get :start
      get :unstart
      get :publish
      get :unpublish
      get :extend
      get :stop
      get :results
      get :chart
      get :stats
      get :recent_vessels
    end
    resources :players, only: [:index, :new, :create, :destroy], controller: 'competitions/players'
    resources :vessels, only: [:new, :index, :create, :destroy], controller: 'competitions/vessels' do
      collection do
        get :manifest
        post :assign
        get :manage
      end
      member do
        delete :reject
      end
    end
    resources :heats, only: [:index, :show] do
      member do 
        get :start
        get :stop
        get :reset
      end
      resources :vessels, only: :index, controller: 'heats/vessels'
      resources :records, only: :index
      post 'records/batch'
    end
    resource :metric, only: [:edit, :update]
    resources :organizers, controller: 'competitions/organizers'
  end

  resources :evolutions do
    resources :variant_groups do
      member do
        get :generate
      end
    end
  end

  resources :parts, only: [:index, :new, :create, :show, :edit, :update]

  # players are top level objects
  resources :npcs, only: [:new, :create], controller: 'players/npc'
  resources :players do
    resources :vessels, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
      member do
        get :undiscard
        get :sensitivity
      end
    end
    member do
      get :chart
    end
    collection do
      get :register
      get :stats
      get :recent
    end
  end

  resources :roles, only: [:index] do
    member do
      get :promote
      get :demote
    end
  end

  resources :rulesets do
    resources :rules, only: [:index, :new, :create, :destroy]
  end

  # rescue bad routes
  match '*unmatched', to: 'application#bad_request', via: :all
end
