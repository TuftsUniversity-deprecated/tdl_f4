module PidMethods


  def self.ingested?(pid)
    result = false
    f4_id = ""

    if pid.start_with?("tufts:")
      solr_connection = ActiveFedora.solr.conn
      fq = 'legacy_pid_tesim:"' + pid + '"'

      response = solr_connection.get 'select', params: { fq: fq, rows: '1' }
      collection_length = response['response']['docs'].length

      if collection_length > 0
        result = true
        f4_id = response['response']['docs'][0]['id']
      end

      result = (collection_length > 0)
    else
      begin
        ActiveFedora::Base.load_instance_from_solr(pid)
        f4_id = pid
        result = true
      rescue
      end
    end

    return result, f4_id
  end


end
