# Generated via
#  `rails generate curation_concerns:work TuftsEad`

module CurationConcerns
  class TuftsEadsController < ApplicationController
    helper :eads
    include CurationConcerns::CurationConcernController
    include WithLimitedFileSets
    include WithEads
    self.curation_concern_type = TuftsEad

    before_action :load_fedora_document
  
    def fa_overview
      @id = params[:id]
    end

    def fa_series
      @id = params[:id]
      @item_id = params[:item_id]
    end

  end
end
