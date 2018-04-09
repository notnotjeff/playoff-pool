Rails.application.routes.draw do
  devise_for :users

  root 'static_pages#home'

  resources :users do
    resources :rosters
    resources :general_managers, only: [:show, :edit]
  end

  resources :leagues
  resources :general_managers, only: [:destroy, :update, :create]
  resources :skaters, only: [:index, :show]
  resources :roster_players, only: [:create, :destroy]
end
