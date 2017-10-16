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
      @transcript_download_path = nil
      @media_play_path = nil
      @media_download_path = nil

      return unless @document_fedora.class.name == "TuftsAudio" ||  @document_fedora.class.name == "TuftsVideo"

      file_sets = @document_fedora.file_sets

      return if file_sets.nil?

      file_sets.each do |file_set|
        original_file = file_set.original_file
        unless original_file.nil?
          if original_file.mime_type == "text/xml"
            @transcript_download_path = main_app.download_path(file_set)
            @document_tei = Datastreams::Tei.from_xml(original_file.content)
            @document_tei.ng_xml.remove_namespaces! unless @document_tei.nil?
          else
            filename_extension = (@document_fedora.class.name == "TuftsAudio" ? "mp3" : "mp4");
            derivative_paths = CurationConcerns::DerivativePath.derivatives_for_reference(file_set)
            derivative_paths.each do |derivative_path|
              if derivative_path.end_with?(filename_extension)
                @media_play_path = main_app.download_path(file_set)
                @media_download_path = main_app.download_path(file_set, file: filename_extension) + "&download=true"
                break
              end
            end
          end
        end
      end
    end
  end
end
