# Generated via
#  `rails generate curation_concerns:work TuftsAudio`

module CurationConcerns
  class TuftsAudiosController < ApplicationController
    helper :transcripts
    include CurationConcerns::CurationConcernController
    include WithLimitedFileSets
    include WithTranscripts
    self.max_allowable_file_sets = 2
    self.curation_concern_type = TuftsAudio

    before_action :load_fedora_document


    def audio_transcriptonly
      respond_to do |wants|
        wants.html { presenter && parent_presenter }
      end
    end
  end
end
