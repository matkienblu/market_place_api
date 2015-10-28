require 'api_constraints'

MarketPlaceApi::Application.routes.draw do
  # API definition
  namespace :api, defaults: {format: :json}, constraints: {subdomain: 'api'}, path: '/' do
    devise_for :users
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :users, :only => [:show, :create, :update, :destroy]
      resources :sessions, :only => [:create, :destroy]
    end
  end
end
