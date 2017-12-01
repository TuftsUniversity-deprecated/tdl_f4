module RcrsHelper


  def self.relationship_page_path(id)
    "/concern/tufts_rcrs/" + id
  end


  def self.collection_page_path(id)
    "/concern/tufts_eads/" + id
  end


  def self.title(rcr)
    result = ""
    title = rcr.find_by_terms_and_value(:title)
    result = title.first.text unless title.nil? || title.empty?

    return result
  end


  def self.dates(rcr)
    result = ""
    from_date = rcr.find_by_terms_and_value(:fromDate)
    to_date = rcr.find_by_terms_and_value(:toDate)
    result = from_date.first.text unless from_date.nil? || from_date.empty?
    result += "-"
    result += to_date.first.text unless to_date.nil? || to_date.empty? 

    return result
  end


  def self.abstract(rcr)
    result = ""
    bioghist_abstract = rcr.find_by_terms_and_value(:bioghist_abstract)
    result = bioghist_abstract.first.text unless bioghist_abstract.nil? || bioghist_abstract.empty?

    return result
  end


  def self.history(rcr)
    return rcr.find_by_terms_and_value(:bioghist_p)
  end


  def self.structure_or_genealogy_p(rcr)
    return rcr.find_by_terms_and_value(:structure_or_genealogy_p)
  end


  def self.structure_or_genealogy_items(rcr)
    return rcr.find_by_terms_and_value(:structure_or_genealogy_item)
  end


  def self.relationships(rcr)
    relationship_hash = {
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


  def self.collections(rcr)
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
