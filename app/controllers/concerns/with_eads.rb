module WithEads
  extend ActiveSupport::Concern
  included do
    # Use params[:id] to load an object from Fedora.
    # Sets @document_fedora with the loaded object.
    # Sets @document_ead with the EAD file_set content of the loaded object.
    def load_fedora_document
      return unless params[:id].present?

      @document_fedora = ActiveFedora::Base.find(params[:id])

      return unless @document_fedora.class.instance_of?(TuftsEad.class)

      @document_ead = Datastreams::Ead.from_xml(@document_fedora.file_sets.first.original_file.content)
      @document_ead.ng_xml.remove_namespaces! unless @document_ead.nil?
    end
  end
end
