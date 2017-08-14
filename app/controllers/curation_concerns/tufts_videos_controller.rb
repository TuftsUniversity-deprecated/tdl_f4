# Generated via
#  `rails generate curation_concerns:work TuftsVideo`

module CurationConcerns
  class TuftsVideosController < ApplicationController
    helper :transcripts
    include CurationConcerns::CurationConcernController
    include WithLimitedFileSets
    include WithTranscripts
    self.max_allowable_file_sets = 2
    self.curation_concern_type = TuftsVideo

    before_action :load_fedora_document


    def transcriptonly
    end
  end
end
