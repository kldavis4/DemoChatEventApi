MarketPlaceApi::Application.routes.draw do
  # Api definition
  namespace :api, defaults: { format: :json } do,
                              constraints: { subdomain: 'api' }, path: '/'  do
    # We are going to list our resources here
  end
end
