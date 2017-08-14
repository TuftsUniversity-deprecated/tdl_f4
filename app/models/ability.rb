class Ability
  include Hydra::Ability
  
  include CurationConcerns::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
    
    can [:fa_overview], ActiveFedora::Base
    can [:fa_series], ActiveFedora::Base
    can [:audio_transcriptonly], ActiveFedora::Base
    can [:video_transcriptonly], ActiveFedora::Base
  end
end
