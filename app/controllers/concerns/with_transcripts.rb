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
      return if @document_fedora.file_sets.nil? || @document_fedora.file_sets.second.nil? || @document_fedora.file_sets.second.original_file.nil?

      @document_tei = Datastreams::Tei.from_xml(@document_fedora.file_sets.second.original_file.content)
      @document_tei.ng_xml.remove_namespaces! unless @document_tei.nil?
    end
  end
end
