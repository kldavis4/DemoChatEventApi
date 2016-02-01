require 'api_constraints'

EventApi::Application.routes.draw do
  # Api definition
  namespace :api, defaults: { format: :json },
                              constraints: { subdomain: 'api' }, path: '/'  do
    scope module: :v1,
              constraints: ApiConstraints.new(version: 1, default: true) do
      # We are going to list our resources here
      resources :events, :only => [:index, :show, :create] do
        collection do
          post 'clear'
          get 'summary'
        end
      end
    end
  end
end
