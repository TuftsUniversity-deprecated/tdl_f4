module ApplicationHelper

  ##
  # Returns the appropriate partial path for the specified model
  #
  # @param model {string} The model name.
  def model_partial_registry(model)
    case model
    when 'TuftsImage'
      'curation_concerns/tufts_images/show_image'
    when 'TuftsEad'
      'curation_concerns/tufts_eads/show_ead'
    when 'TuftsVotingRecord'
      'curation_concerns/tufts_voting_records/show_voting_record'
    when "TuftsAudio"
      'curation_concerns/tufts_audios/show_audio'
    when "TuftsVideo"
      'curation_concerns/tufts_videos/show_video'
    when 'TuftsTei'
        'curation_concerns/tufts_teis/show_tei'
    else
      'curation_concerns/base/show_curation_concern'
    end
  end
end
