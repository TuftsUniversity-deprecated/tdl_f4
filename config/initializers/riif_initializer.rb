# Tell RIIIF to get files via HTTP (not from the local disk)
Riiif::Image.file_resolver = Riiif::HTTPFileResolver.new

# This tells RIIIF how to resolve the identifier to a URI in Fedora
Riiif::Image.file_resolver.id_to_uri = lambda do |id| 
#  ActiveFedora::Base.id_to_uri(CGI.unescape(id)).tap do |url|
#    logger.info "Riiif resolved #{id} to #{url}"
#  end
Rails.cache.fetch("#{id}/original_file", expires_in: 3.months) do
    FileSet.find(CGI.unescape(id)).original_file.uri
  end
end
#Riiif::Image.authorization_service = lambda do0#
# In order to return the info.json endpoint, we have to have the full height and width of
# each image. If you are using hydra-file_characterization, you have the height & width 
# cached in Solr. The following block directs the info_service to return those values:
Riiif::Image.info_service = lambda do |id, image|
  # id will look like a path to a pcdm:file
  # (e.g. rv042t299%2Ffiles%2F6d71677a-4f80-42f1-ae58-ed1063fd79c7)
  # but we just want the id for the FileSet it's attached to.
byebug
  # Capture everything before the first slash
  fs_id = id.sub(/\A([^\/]*)\/.*/, '\1')
  resp = ActiveFedora::SolrService.get("id:#{fs_id}")
  doc = resp['response']['docs'].first
  raise "Unable to find solr document with id:#{fs_id}" unless doc
  { height: doc['height_is'], width: doc['width_is'] }
end

def logger
  Rails.logger
end

Riiif::Engine.config.cache_duration_in_days = 30
Riiif::Image.file_resolver.basic_auth_credentials = [ActiveFedora::Fedora.instance.user, ActiveFedora::Fedora.instance.password]