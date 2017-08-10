module WithTranscripts
  extend ActiveSupport::Concern
  included do
    # Use params[:id] to load an object from Fedora.
    # Sets @document_fedora with the loaded object.
    # Sets @document_tei with the TEI file_set content of the loaded object.
    def load_fedora_document
      return unless params[:id].present?

      @document_fedora = ActiveFedora::Base.find(params[:id])
      @document_tei = nil

      return unless @document_fedora.class.instance_of?(TuftsAudio.class) ||  @document_fedora.class.instance_of?(TuftsVideo.class)

      file_sets = @document_fedora.file_sets

      return if file_sets.nil?

Rails.logger.debug(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> file_sets.size " + file_sets.size.to_s)
      file_sets.each do |file_set|
        original_file = file_set.original_file
        unless original_file.nil?
Rails.logger.debug(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> original file mime type is " + original_file.mime_type)
Rails.logger.debug(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> file_set.files.size is " + file_set.files.size.to_s)
          if original_file.mime_type == "text/xml"
            @document_tei = Datastreams::Tei.from_xml(original_file.content)
            @document_tei.ng_xml.remove_namespaces! unless @document_tei.nil?
#            break;
          end
        end
      end
    end
  end
end
