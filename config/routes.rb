require 'api_constraints'

MarketPlaceApi::Application.routes.draw do
  # API definition
  namespace :api, defaults: {format: :json}, constraints: {subdomain: 'api'}, path: '/' do

    devise_for :users
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: false) do
      resources :users, :only => [:show, :create, :update, :destroy,:index] do
        resources :products, :only => [:create, :update, :destroy]
      end
      resources :sessions, :only => [:create, :destroy]
      resources :products, :only => [:show, :index]
    end

    scope module: :v2, constraints: ApiConstraints.new(version: 2, default: false) do
      resources :users, :only => [:index]
    end

  end
end
