module CurationConcerns
  class TuftsRcrsController < ApplicationController
    helper :rcrs
    include CurationConcerns::CurationConcernController
    include WithLimitedFileSets
    include WithRcrs
    self.curation_concern_type = TuftsRcr

    before_action :load_fedora_document
  
  end
end
