Rails.application.routes.draw do
  mount TuftsModelsNg::Engine => "/", as: "tufts_models_engine"
 mount UserImpersonate::Engine => "/impersonate", as: "impersonate_engine"
  mount Riiif::Engine => '/image-service', as: 'riiif'

  mount Blacklight::Engine => '/'
  
    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users
  mount CurationConcerns::Engine, at: '/'
#  resources :welcome, only: 'index'
  root 'catalog#index'
  curation_concerns_collections
  curation_concerns_basic_routes
  curation_concerns_embargo_management
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  get 'finding_aids/:id/:item_id' => 'catalog#fa_series', as: :fa_series
  get 'finding_aids/:id' => 'catalog#fa_overview', as: :fa_overview

#   get 'products/:id' => 'catalog#view'
#   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

# match '/catalog/ead/:id/:item_id', :to => 'catalog#eadinternal', :constraints => {:id => /.*/, :item_id => /.*/}, :as =>'eadinternal'
# match '/catalog/ead/:id', :to => 'catalog#eadoverview', :constraints => {:id => /.*/}, :as =>'eadoverview'

end
