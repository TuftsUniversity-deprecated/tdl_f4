module RcrsHelper


# This is also used in eads_helper.rb and should be moved out to a common place.
# I modified it to find legacy pids.
  def ingested?(pid)
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

  def title(rcr)
    return rcr.find_by_terms_and_value(:title).first.text
  end


  def dates(rcr)
    return rcr.find_by_terms_and_value(:fromDate).first.text +
      "-" +
      rcr.find_by_terms_and_value(:toDate).first.text
  end


  def abstract(rcr)
    return rcr.find_by_terms_and_value(:bioghist_abstract).first.text
  end


  def abstract(rcr)
    return rcr.find_by_terms_and_value(:bioghist_abstract).first.text
  end


  def history(rcr)
    return rcr.find_by_terms_and_value(:bioghist_p)
  end


  def structure_or_genealogy_p(rcr)
    return rcr.find_by_terms_and_value(:structure_or_genealogy_p)
  end


  def structure_or_genealogy_items(rcr)
    return rcr.find_by_terms_and_value(:structure_or_genealogy_item)
  end


  def relationships(rcr)
    relationship_hash = {"isPartOf" => "Part of",
      "reportsTo" => "Reports to",
      "hasReport" => "Has report",
      "isPartOf" => "Part of",
      "hasPart" => "Has part",
      "isMemberOf" => "Member of",
      "hasMember" => "Has member",
      "isPrecededBy" => "Preceded by",
      "isFollowedBy" => "Followed by",
      "isAssociatedWith" => "Associated with",
      "isChildOf" => "Child of",
      "isParentOf" => "Parent of",
      "isCousinOf" => "Cousin of",
      "isSiblingOf" => "Sibling of",
      "isSpouseOf" => "Spouse of",
      "isGrandchildOf" => "Grandchild of",
      "isGrandparentOf" => "Grandparent of"}
    result_hash = {}
    relationships = rcr.find_by_terms_and_value(:cpf_relations)

    relationships.each do |relationship|
      role = relationship_hash.fetch(relationship.attribute("arcrole").text.sub("http://dca.lib.tufts.edu/ontology/rcr#", ""), "Unknown relationship")  # xlink:arcrole in the EAC
      name = ""
      pid = ""
      from_date = ""
      to_date = ""

      relationship.element_children.each do |child|
        childname = child.name

        if childname == "relationEntry"
          name = child.text
          pid = child.attribute("id")  # xml:id in the EAC
        elsif childname == "dateRange"
          child.element_children.each do |grandchild|
            grandchildname = grandchild.name

            if grandchildname == "fromDate"
              from_date = grandchild.text
            elsif grandchildname == "toDate"
              to_date = grandchild.text
            end
          end
        end
      end

      role_array = result_hash.fetch(role, nil)

      if role_array.nil?
        role_array = []
        result_hash.store(role, role_array)
      end

      role_array << {:name => name, :pid => pid, :from_date => from_date, :to_date => to_date}
    end

    return result_hash
  end


  def collections(rcr)
    result_array = []
    collections = rcr.find_by_terms_and_value(:resource_relations)

    collections.each do |collection|
      name = ""
      pid = collection.attribute("id").text  # xml:id in the EAC

      collection.element_children.each do |child|
        childname = child.name

        if childname == "relationEntry"
          name = child.text
          break
        end
      end

      result_array << {:name => name, :pid => pid}
    end

    return result_array
  end


end