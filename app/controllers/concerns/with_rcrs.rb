module WithRcrs
  extend ActiveSupport::Concern
  included do
    # Use params[:id] to load an object from Fedora.
    # Sets @document_fedora with the loaded object.
    # Sets @document_rcr with the RCR (EAC) file_set content of the loaded object.
    def load_fedora_document
      return unless params[:id].present?

      @document_fedora = ActiveFedora::Base.find(params[:id])
      @document_rcr = nil

      return unless @document_fedora.class.instance_of?(TuftsRcr.class)
      return if @document_fedora.file_sets.nil? || @document_fedora.file_sets.first.nil? || @document_fedora.file_sets.first.original_file.nil?

      @document_rcr = Datastreams::Rcr.from_xml(@document_fedora.file_sets.first.original_file.content)
    end
  end
end
