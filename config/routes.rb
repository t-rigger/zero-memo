Rails.application.routes.draw do
  devise_for :users
  
  resources :memo_sets, only: [:create, :show] do
    member do
      get :complete
      get :download
      post :send_email
    end
  end
  
  resources :memos, only: [:show, :update] do
    resources :lines, only: [:create]
  end
  
  root "home#index"
end
