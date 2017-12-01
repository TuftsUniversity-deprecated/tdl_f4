module MetadataMethods


  def self.get_metadata(fedora_obj)
    datastream = fedora_obj.datastreams["DCA-META"]

    # create the union (ie, without duplicates) of subject, geogname, persname, and corpname
    subjects = []
    union(subjects, datastream.find_by_terms_and_value(:subject))
    union(subjects, datastream.find_by_terms_and_value(:geogname))
    union(subjects, datastream.find_by_terms_and_value(:persname))
    union(subjects, datastream.find_by_terms_and_value(:corpname))

    return {
      :titles => datastream.find_by_terms_and_value(:title),
      :creators => datastream.find_by_terms_and_value(:creator),
      :dates => datastream.find_by_terms_and_value(:dateCreated),
      :descriptions => datastream.find_by_terms_and_value(:description),
      :sources => datastream.find_by_terms_and_value(:source2),
      :citable_urls => datastream.find_by_terms_and_value(:identifier),
      :citations => datastream.find_by_terms_and_value(:bibliographicCitation),
      :publishers => datastream.find_by_terms_and_value(:publisher),
      :genres => datastream.find_by_terms_and_value(:genre),
      :types => datastream.find_by_terms_and_value(:type2),
      :formats => datastream.find_by_terms_and_value(:format2),
      :rights => datastream.find_by_terms_and_value(:rights),
      :subjects => subjects,
      :temporals => datastream.find_by_terms_and_value(:temporal)
    }
  end


  def self.union(array1, array2)
    # Params are two arrays of Nokogiri elements.  Add elements of array2 to array1 and return array1.
    # Leave out duplicate elements, where e.g. <dcadesc:geogname>Somerville (Mass.)</dcadesc:geogname> and
    # <dcadesc:subject>Somerville (Mass.)</dcadesc:subject> are defined as duplicate (i.e., their .text is ==).

    array2.each do |element2|
      dup = false

      array1.each do |element1|
        if element1 == element2
          dup = true
          break
        end
      end

      if !dup
        array1 << element2
      end
    end

    return array1
  end


end