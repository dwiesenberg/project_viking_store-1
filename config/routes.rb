Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'products#index'
  resources :products, only: [:index, :show]
  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create, :edit, :update, :destroy]
  resources :orders, only: [:edit, :update, :destroy, :create]
  resources :carts, only: [:edit, :update, :create, :destroy]
  resources :credit_cards, only: [:destroy]


  namespace :admin do
    root 'dashboard#index', as: :root
    resources :categories
    resources :products
    resources :addresses, only: [:index]
    resources :orders, only: [:index]
    resources :purchases, only: [:create, :update, :destroy]
    resources :users do
      resources :addresses
      resources :orders
    end
    resources :credit_cards, only: [:destroy]
  end
end
