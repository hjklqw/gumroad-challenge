Rails.application.routes.draw do
  get 'homepage/index'
  namespace :api do
    get 'question/:id', to: 'question#get'
    post 'ask', to: 'question#ask'
  end
  root 'homepage#index'
  get 'question/:id' => 'homepage#index'
end
