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
  
  end
end
