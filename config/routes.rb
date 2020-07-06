Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :records do
    collection do
      post :batch
    end
  end
  resources :competitions do
    resources :records, only: :index
  end
end
