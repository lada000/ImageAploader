Rails.application.routes.draw do
  resources :images, only: [:create] do
    member do
      get ':size', to: 'images#show', constraints: { size: /small|medium|large/ }, as: :size
    end
  end
end
