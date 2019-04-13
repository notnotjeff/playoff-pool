# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root 'static_pages#home'

  resources :users do
    resources :rosters
    resources :general_managers, only: %i[show edit]
  end

  resources :leagues do
    member do
      get :skaters, :goalies, :rules, :active_players
    end
  end
  resources :general_managers, only: %i[destroy update create]
  resources :skaters, only: %i[index show]
  resources :roster_players, only: %i[create destroy] do
    collection { post :import }
  end

  if Rails.env.development?
    get '/updater', to: 'static_pages#updater'
  end
end
