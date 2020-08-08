Rails.application.routes.draw do
  resources :sources
  resources :words
  get 'tools', to: 'tools#index'
  get 'tools/substitute', to: 'tools#substitution_test'


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'words#index'
end
