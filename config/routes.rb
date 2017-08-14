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
  resources :welcome, only: 'index'
  root 'catalog#welcome'
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

  get 'concern/tufts_eads/:id/fa/:item_id' => 'curation_concerns/tufts_eads#fa_series', :constraints => {:id => /.*/, :item_id => /.*/}, as: :fa_series
  get 'concern/tufts_eads/:id/fa' => 'curation_concerns/tufts_eads#fa_overview', :constraints => {:id => /.*/}, as: :fa_overview
  get 'concern/tufts_audios/:id/transcriptonly', :to => 'curation_concerns/tufts_audios#audio_transcriptonly', :constraints => {:id => /.*/}, :as =>'audio_transcriptonly'
  get 'concern/tufts_videos/:id/transcriptonly', :to => 'curation_concerns/tufts_videos#video_transcriptonly', :constraints => {:id => /.*/}, :as =>'video_transcriptonly'

  get "/pages/*id" => 'pages#show', as: :page, format: false

#   get 'products/:id' => 'catalog#view'
#   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

end
