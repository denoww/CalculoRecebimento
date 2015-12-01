Rails.application.routes.draw do
  root 'cobrancas#index'

  resources :cobrancas
  resources :recebimentos, only: [:create, :destroy]
  resources :composicao_cobrancas, only: [:create, :destroy]
  resources :config_cobranca, only: [:update]
  post '/recebimentos/calcular_divida', to: 'recebimentos#calcular_divida'
end
