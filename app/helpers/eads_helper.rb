module EadsHelper


  def collection_has_online_content(unitid)
    solr_connection = ActiveFedora.solr.conn
    fq = 'source_tesim:' + unitid

    response = solr_connection.get 'select', params: { fq: fq, rows: '1' }
    collection_length = response['response']['docs'].length

    collection_length > 0
  end


# This came from tuftsification_hydra's lib/tufts/pid_methods.rb -- is it used elsewhere???
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


# This came from tuftsification_hydra's lib/tufts/metadata_methods.rb -- is it used elsewhere???
  def get_metadata(fedora_obj)
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


# This came from tuftsification_hydra's lib/tufts/metadata_methods.rb -- is it used elsewhere???
  def union(array1, array2)
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


  def landing_page_path(id)
    "/concern/tufts_eads/" + id
  end


  def finding_aid_overview_path(id)
    "/concern/tufts_eads/" + id + "/fa"
  end


  def finding_aid_series_path(id, item_id)
    "/concern/tufts_eads/" + id + "/fa/" + item_id
  end


  def eadid(ead)
    result = ""
    url = ""
    eadid = ead.find_by_terms_and_value(:eadid)
    unless eadid.nil? || eadid.empty?
      first_eadid = eadid.first
      result = first_eadid.text
      url_attr = first_eadid.attribute("url")
      url = url_attr.text unless url_attr.nil?
    end

    return result, url
  end


  def title(ead, includeDate = true)
    full_title = ""
    raw_title = ""
    date = ""
    bulk_date = ""
    unittitles = ead.find_by_terms_and_value(:unittitle)
    unless unittitles.nil? || unittitles.empty?
      raw_title = unittitles.first.text
      if (includeDate)
        date, bulk_date = unitdate(ead)
        full_title = raw_title + (date.empty? ? "" : ", " + date)
      else
        full_title = raw_title
      end
    end

    return full_title, raw_title, date, bulk_date
  end


  def physdesc(ead)
    result = ""
    physdescs = ead.find_by_terms_and_value(:physdesc)

    unless physdescs.nil?
      physdescs.each do |physdesc|
        physdesc.children.each do |child|
          # <physdesc>'s text is a child;  also process text of any <extent> or other child elements
          child_text = child.text.lstrip.rstrip
          unless child_text.empty?
            result << (result.empty? ? "" :  ", ") + child_text
          end
        end
      end
    end

    return result
  end


  def physdesc_split(ead)
    result = ""
    physdescs = ead.find_by_terms_and_value(:physdesc)

    unless physdescs.nil?
      physdescs.each do |physdesc|
        physdesc.children.each do |child|
          # <physdesc>'s text is a child;  also process text of any <extent> or other child elements
          child_text = child.text.strip
          next if child_text.empty?
          child_text.split(";").each do |child_text_part| # also split on semi-colons
            child_text_part_text = child_text_part.strip
            unless child_text_part_text.empty?
              result << (result.empty? ? "" : "<br>") + child_text_part_text
            end
          end
        end
      end
    end

    result
  end


  def abstract(ead)
    result = ""
    abstract = ead.find_by_terms_and_value(:abstract)

    if abstract.nil? || abstract.empty?
      bioghistps = ead.find_by_terms_and_value(:bioghistp)
      result = bioghistps.first.text unless bioghistps.nil? || bioghistps.empty?
    else
      result = abstract.first.text
    end

    result
  end


  def get_bioghist(ead)
    result = []
    bioghistps = ead.find_by_terms_and_value(:bioghistp)

    unless bioghistps.nil?
      bioghistps.each do |bioghistp|
        result << bioghistp.text
      end
    end

    return result
  end


  def unitdate(ead)
    date = ""
    bulk_date = ""
    unitdates = ead.find_by_terms_and_value(:unitdate)
    unless unitdates.nil?
      unitdates.each do |unitdate|
        datetype = unitdate.attribute("type")
        if datetype.nil? || datetype.text == "inclusive"
          date = unitdate.text
        elsif !datetype.nil? && datetype.text == "bulk"
          bulk_date = unitdate.text
        end
      end
    end

    return date, bulk_date
  end


  def unitid(ead)
    result = ""
    unitid = ead.find_by_terms_and_value(:unitid)

    unless unitid.nil?
      result = unitid.text
    end

    return result
  end


  def author(ead)
    result = ""
    persname = ead.find_by_terms_and_value(:persname)

    unless persname.nil?
      result = persname.text.strip
    end

   return result
  end


  def read_more_about(ead)
    # read_more_about ONLY returns <persname>, <corpname> or <famname> that have urls and which have been ingested.
    result = ""
    persname = ead.find_by_terms_and_value(:persname)
    corpname = ead.find_by_terms_and_value(:corpname)
    famname = ead.find_by_terms_and_value(:famname)
    name = ""
    rcr_url = ""

    if !persname.nil? && !persname.empty?
      name, rcr_url = parse_origination(persname)
    elsif !corpname.nil? && !corpname.empty?
      name, rcr_url = parse_origination(corpname)
    elsif !famname.nil? && !famname.empty?
      name, rcr_url = parse_origination(famname)
    end

    if !name.empty? && !rcr_url.empty?
      rcr_url = "tufts:" + rcr_url
      ingested, f4_id = ingested?(rcr_url)
      if ingested
        result = "<a href=\"/concern/tufts_rcrs/" + f4_id + "\">" + name + "</a>"
      end
    end

    return result
  end


  def creator(ead)
    # creator returns <persname>, <corpname> or <famname>, with a link for ones that have urls and which have been ingested.
    result = ""
    persname = ead.find_by_terms_and_value(:persname)
    corpname = ead.find_by_terms_and_value(:corpname)
    famname = ead.find_by_terms_and_value(:famname)
    name = ""
    rcr_url = ""
    ingested = false

    if !persname.nil? && !persname.empty?
      name, rcr_url = parse_origination(persname)
    elsif !corpname.nil? && !corpname.empty?
      name, rcr_url = parse_origination(corpname)
    elsif !famname.nil? && !famname.empty?
      name, rcr_url = parse_origination(famname)
    end

    unless name.empty?
      unless rcr_url.empty?
        rcr_url = "tufts:" + rcr_url
        ingested, f4_id = ingested?(rcr_url)
      end

      if ingested
        result = "<a href=\"/concern/tufts_rcrs/" + f4_id + "\">" + name + "</a>"
      else
        result = name
      end
    end

    return result
  end


  def location(ead)
    result = []
    publicationstmt = ead.find_by_terms_and_value(:publicationstmt)
    unless publicationstmt.nil?
      publicationstmt.children.each do |element_child|
        if element_child.name == "publisher"
          result << element_child.text
        elsif element_child.name == "address"
          element_child.children.each do |addressline|
            text = addressline.text

            # Ignore physical <addressline> elements;  only the email address and URL are wanted.
            if text.include?("@")
              # email address
              result << text
            else
              addressline_children = addressline.element_children
              unless addressline_children.empty?
                first_child = addressline_children.first
                if first_child.name == "extptr"
                  href = first_child.attribute("href")
                  unless href.nil?
                    # URL
                    href_text = href.text
                    result << "<a href=""" + href_text + " target=\"blank\">" + href_text + "</a>"
                  end
                end
              end
            end
          end
        end
      end
    end

   return result
  end


  def langmaterial(ead)
    result = []
    langmaterials = ead.find_by_terms_and_value(:langmaterial)

    unless langmaterials.nil?
      langmaterials.each do |langmaterial|
        primary = false

        langmaterial.element_children.each do |child|
          if child.name == "language"
            primary = true
            break
          end
        end

        unless primary
          result << langmaterial.text
        end
      end
    end

    return result
  end


  def get_arrangement(ead)
    result = []
    arrangementps = ead.find_by_terms_and_value(:arrangementp)

    unless arrangementps.nil?
      arrangementps.each do |arrangementp|
        result << arrangementp.text
      end
    end

    return result
  end


  def get_contents(ead)
    result = []
    scopecontentps = ead.find_by_terms_and_value(:scopecontentp)

    unless scopecontentps.nil?
      scopecontentps.each do |scopecontentp|
        result << scopecontentp.text
      end
    end

    return result
  end


  def get_serieses(ead)
    result = []
    serieses = ead.find_by_terms_and_value(:series)

    unless serieses.nil? || serieses.empty?
      result = serieses
    else
      serieses = ead.find_by_terms_and_value(:aspaceseries)

      unless serieses.nil? || serieses.empty?
        result = serieses
      end
    end

    return result
  end


  def get_series_elements(series)
    series_id = series.attribute("id").text
    did = nil
    scopecontent = nil
    c02s = []
    is_series = series.attribute("level").text == "series"

    # find the pertinent child elements: did, scopecontent and c02
    series.element_children.each do |element_child|
      childname = element_child.name
      if childname == "did"
        did = element_child
      elsif childname == "scopecontent"
        scopecontent = element_child
      elsif childname == "c02" || childname == "c"
        # This method is only called from the overview page, so the series parameter
        # will be a c01 or c02 (or a c in the new ASpace EADs).  But the overview page
        # only cares about c02s because it only shows first-level serieses and second-
        # level sub-serieses.  For that reason it's never necessary to look for c03s here.
        # ASpace EADs may have third-level <c> elements when this is called for second-
        # level <c> tags and it's OK to return them because they'll be ignored.
        level = element_child.attribute("level")
        if !level.nil? && level.text == "subseries"
          c02s << element_child
        end
      end
    end

    return series_id, did, scopecontent, c02s, is_series
  end


  def get_series_title(did, ead_id, series_id, series_level, with_link)
    result = ""

    # process the did element
    unless did.nil?
      unittitle = ""
      unitdate = ""

      did.element_children.each do |did_child|
        childname = did_child.name
        if childname == "unittitle"
          unittitle = did_child.text
        elsif childname == "unitdate"
          datetype = did_child.attribute("type")
          unless !datetype.nil? && datetype.text == "bulk"
            unitdate = did_child.text
          end
        end

        unless unittitle.empty? || unitdate.empty?
          break  # found both, stop looking
        end
      end

      # This should be a link if there are no subseries elements (ie, <c02 level="subseries"> tags).
      # As of TDLR-667 all series titles will be links.
      # As of TDLR-664 with_link will be false for top-level elements which are leaf-level items.
      unless unittitle.empty?
        result = (series_level.empty? ? "" : series_level + ". ") + (with_link ? "<a data-turbolinks=\"false\" href=\"" + finding_aid_series_path(ead_id, series_id) + "\">" : "") + unittitle + (unitdate.empty? ? "" : ", " + unitdate) + (with_link ? "</a>" : "")
      end
    end

    return result
  end


  def get_scopecontent_paragraphs(scopecontent)
    result = []

    # process the scopecontent element
    unless scopecontent.nil?
      scopecontent.element_children.each do |scopecontent_child|
        childname = scopecontent_child.name
        if childname == "p"
          result << scopecontent_child.text
        elsif childname == "note"
          scopecontent_child.element_children.each do |note_child|
            if note_child.name == "p"
              result << note_child.text
            end
          end
        end
      end
    end

    return result
  end


  def get_paragraphs(element)
    result = []

    unless element.nil?
      element.element_children.each do |element_child|
        if element_child.name == "p"
          result << element_child.text
        end
      end

      if result.empty?  # No <p> was found, so use the full text of the element.
        result << element.text
      end
    end

    return result
  end


  def get_other_finding_aids_paragraphs(element)
    result = []

    unless element.nil?
      element.element_children.each do |element_child|
        if element_child.name == "p"
          element_child.search(:extref).each do |extref|
            extref.content = '<a href="' + extref.text + '" target="blank">' + extref.text + '</a>'
          end
          element_child.search(:extptr).each do |extptr|
            extptr_href = extptr.attribute('href')
            unless extptr_href.nil?
              extptr_title = extptr.attribute('title')
              extptr.content = '<a href="' + extptr_href.text + '" target="blank">' + (extptr_title.nil? ? extptr_href.text : extptr_title.text) + '</a>'
            end
          end
          result << element_child.text
        end
      end

      if result.empty?  # No <p> was found, so use the full text of the element.
        result << element.text
      end
    end

    return result
  end


  def get_names_and_subjects(ead)
    result = []
    controlaccesses = ead.find_by_terms_and_value(:controlaccess)

    unless controlaccesses.nil?
      controlaccesses.each do |controlaccess|
        controlaccess.element_children.each do |element_child|
          childname = element_child.name

          if childname == "persname" || childname == "corpname" || childname == "subject" || childname == "geogname" ||
              childname == "title" || childname == "genreform" || childname == "famname"
            child_text = element_child.text
            child_id = element_child.attribute("id")
            child_url = (child_id.nil? ? "" : ("tufts:" + child_id.text))

            unless child_text.empty?
              ingested = false
              unless child_url.empty?
                ingested, f4_id = ingested?(child_url)
              end
              result << (ingested ? "<a href=\"/concern/tufts_rcrs/" + f4_id + "\">" : "") + child_text + (ingested ? "</a>" : "")
            end
          end
        end
      end
    end

    return result
  end


  def get_related_material(ead)
    result = []
    relatedmaterialps = ead.find_by_terms_and_value(:relatedmaterialp)

    unless relatedmaterialps.nil?
      relatedmaterialps.each do |relatedmaterialp|
        result << relatedmaterialp.text
      end
    end

    return result
  end


  def get_separated_material(ead)
    result = []
    separatedmaterialps = ead.find_by_terms_and_value(:separatedmaterialp)

    unless separatedmaterialps.nil?
      separatedmaterialps.each do |separatedmaterialp|
        result << separatedmaterialp.text
      end
    end

    return result
  end


  def get_access_restrictions(ead)
    result = []
    accessrestrictps = ead.find_by_terms_and_value(:accessrestrictp)
    descgrpaccessrestrictps = ead.find_by_terms_and_value(:descgrpaccessrestrictp)

    unless accessrestrictps.nil?
      accessrestrictps.each do |accessrestrictp|
        result << accessrestrictp.text
      end
    end

    unless descgrpaccessrestrictps.nil?
      descgrpaccessrestrictps.each do |descgrpaccessrestrictp|
        result << descgrpaccessrestrictp.text
      end
    end

    return result
  end


  def get_use_restrictions(ead)
    result = []
    userestrictps = ead.find_by_terms_and_value(:userestrictp)
    descgrpuserestrictps = ead.find_by_terms_and_value(:descgrpuserestrictp)

    unless userestrictps.nil?
      userestrictps.each do |userestrictp|
        result << userestrictp.text.sub(Rails.configuration.use_restrict_text_match, Rails.configuration.use_restrict_text_replace)
      end
    end

    unless descgrpuserestrictps.nil?
      descgrpuserestrictps.each do |descgrpuserestrictp|
        result << descgrpuserestrictp.text.sub(Rails.configuration.use_restrict_text_match, Rails.configuration.use_restrict_text_replace)
      end
    end

    return result
  end


  def get_preferred_citation(ead)
    result = []
    preferciteps = ead.find_by_terms_and_value(:prefercitep)
    descgrppreferciteps = ead.find_by_terms_and_value(:descgrpprefercitep)

    # Prefercite doesn't appear in our EADs but someday it could.
    unless preferciteps.nil?
      preferciteps.each do |prefercitep|
        result << prefercitep.text
      end
    end

    unless descgrppreferciteps.nil?
      descgrppreferciteps.each do |descgrpprefercitep|
        result << descgrpprefercitep.text
      end
    end

    return result
  end


  def get_processing_notes(ead)
    result = []
    processinfops = ead.find_by_terms_and_value(:processinfop)

    unless processinfops.nil?
      processinfops.each do |processinfop|
        result << processinfop.text
      end
    end

    return result
  end


  def get_acquisition_info(ead)
    result = []
    acqinfops = ead.find_by_terms_and_value(:acqinfop)

    unless acqinfops.nil?
      acqinfops.each do |acqinfop|
        result << acqinfop.text
      end
    end

    return result
  end


  def get_custodial_history(ead)
    result = []
    custodhistps = ead.find_by_terms_and_value(:custodhistp)

    unless custodhistps.nil?
      custodhistps.each do |custodhistp|
        result << custodhistp.text
      end
    end

    return result
  end


  def get_phystech(ead)
    result = []
    phystechps = ead.find_by_terms_and_value(:phystechp)
    descgrpphystechps = ead.find_by_terms_and_value(:descgrpphystechp)

    unless phystechps.nil?
      phystechps.each do |phystechp|
        result << phystechp.text
      end
    end

    unless descgrpphystechps.nil?
      descgrpphystechps.each do |descgrpphystechp|
        result << descgrpphystechp.text
      end
    end

    return result
  end


  def get_accruals(ead)
    result = []
    accrualsps = ead.find_by_terms_and_value(:accrualsp)

    unless accrualsps.nil?
      accrualsps.each do |accrualsp|
        result << accrualsp.text
      end
    end

    return result
  end


  def get_appraisal(ead)
    result = []
    appraisalps = ead.find_by_terms_and_value(:appraisalp)

    unless appraisalps.nil?
      appraisalps.each do |appraisalp|
        result << appraisalp.text
      end
    end

    return result
  end


  def get_altformavail(ead)
    result = []
    altformavailps = ead.find_by_terms_and_value(:altformavailp)

    unless altformavailps.nil?
      altformavailps.each do |altformavailp|
        result << altformavailp.text
      end
    end

    return result
  end


  def get_originalsloc(ead)
    result = []
    originalslocps = ead.find_by_terms_and_value(:originalslocp)

    unless originalslocps.nil?
      originalslocps.each do |originalslocp|
        result << originalslocp.text
      end
    end

    return result
  end


  def get_otherfindaid(ead)
    result = []
    otherfindaidps = ead.find_by_terms_and_value(:otherfindaidp)

    unless otherfindaidps.nil?
      otherfindaidps.each do |otherfindaidp|
        result << otherfindaidp.text
      end
    end

    return result
  end


  def get_sponsor(ead)
    result = ""

    sponsor = ead.find_by_terms_and_value(:sponsor)

    unless sponsor.nil?
      result = sponsor.text
    end

    return result
  end


  def get_series(ead, item_id)
    series = nil
    series_level = 0
    subseries_level = 0
    serieses = get_serieses(ead)

    unless serieses.nil?
      # look for a c01 whose id matches item_id
      serieses.each do |item|
        series_level += 1
        subseries_level = 0

        if item.attribute("id").text == item_id
          series = item
        else
          # look for a c02 whose id matches item_id
          item.element_children.each do |element_child|
            childname = element_child.name
            if childname == "c02" || childname == "c"
              if element_child.attribute("level").text == "subseries"
                subseries_level += 1

                if element_child.attribute("id").text == item_id
                  series = element_child
                  break
                end
              end
            end
          end
        end

        unless series.nil?
          break  # found it, stop looking
        end
      end
    end

    return series, series_level.to_s + (subseries_level == 0 ? "" : ("." + subseries_level.to_s))
  end


  def get_series_info(series)
    did = nil
    scopecontent = nil
    unittitle = ""
    unitdate = ""
    unitdate_bulk = ""
    creator = ""
    unitid = ""
    physdesc = ""
    title = ""
    paragraphs = []
    series_items = []
    series_langmaterial = []
    series_arrangement = []
    series_access_restrict = []
    series_use_restrict = []
    series_phystech = []
    series_prefercite = []
    series_processinfo = []
    series_acquisition_info = []
    series_custodhist = []
    series_accruals = []
    series_appraisal = []
    series_separated_material = []
    series_names_and_subjects = []
    series_related_material = []
    series_alt_formats = []
    series_originals_loc = []
    series_other_finding_aids = []

    unless series.nil?
      # find the pertinent child elements: did, scopecontent, etc
      series.element_children.each do |element_child|
        childname = element_child.name
        if childname == "did"
          did = element_child
        elsif childname == "scopecontent"
          scopecontent = element_child
        elsif childname == "accessrestrict"
          series_access_restrict = get_paragraphs(element_child)
        elsif childname == "userestrict"
          series_use_restrict = get_paragraphs(element_child)
        elsif childname == "phystech"
          series_phystech = get_paragraphs(element_child)
        elsif childname == "prefercite"
          series_prefercite = get_paragraphs(element_child)
        elsif childname == "arrangement"
          series_arrangement = get_paragraphs(element_child)
        elsif childname == "processinfo"
          series_processinfo = get_paragraphs(element_child)
        elsif childname == "acqinfo"
          series_acquisition_info = get_paragraphs(element_child)
        elsif childname == "custodhist"
          series_custodhist = get_paragraphs(element_child)
        elsif childname == "accruals"
          series_accruals = get_paragraphs(element_child)
        elsif childname == "appraisal"
          series_appraisal = get_paragraphs(element_child)
        elsif childname == "separatedmaterial"
          series_separated_material = get_paragraphs(element_child)
        elsif childname == "relatedmaterial"
          series_related_material = get_paragraphs(element_child)
        elsif childname == "altformavail"
          series_alt_formats = get_paragraphs(element_child)
        elsif childname == "originalsloc"
          series_originals_loc = get_paragraphs(element_child)
        elsif childname == "otherfindaid"
          series_other_finding_aids = get_other_finding_aids_paragraphs(element_child)
        elsif childname == "c02" || childname == "c03" || childname == "c"
          # The series could be a <c01 level="series"> with c02 children, or
          # it could be a <c02 level="subseries"> with c03 children.
          series_items << element_child
        elsif childname == "controlaccess"
          element_child.element_children.each do |element_grandchild|
            grandchildname = element_grandchild.name

            if grandchildname == "persname" || grandchildname == "corpname" || grandchildname == "subject" || grandchildname == "geogname" ||
                grandchildname == "title" || grandchildname == "genreform" || grandchildname == "famname"
              grandchild_text = element_grandchild.text
              grandchild_id = element_grandchild.attribute("id")
              grandchild_url = (grandchild_id.nil? ? "" : grandchild_id.text)

              unless grandchild_text.empty?
                ingested = false
                unless grandchild_url.empty?
                  ingested, f4_id = ingested?(grandchild_url)
                end
                series_names_and_subjects << (ingested ? "<a href=\"/concern/tufts_rcrs/" + f4_id + "\">" : "") + grandchild_text + (ingested ? "</a>" : "")
              end
            end
          end
        end
      end

      # process the did element
      unless did.nil?
        did.element_children.each do |did_child|
          childname = did_child.name
          if childname == "unittitle"
            unittitle = did_child.text
          elsif childname == "unitdate"
            datetype = did_child.attribute("type")
            if datetype.nil? || datetype.text == "inclusive"
              unitdate = did_child.text
            elsif !datetype.nil? && datetype.text == "bulk"
              unitdate_bulk = did_child.text
            end
          elsif childname == "physdesc"
            did_child.children.each do |physdesc_child|
              # <physdesc>'s text is a child;  also process text of any <extent> or other child elements
              physdesc_child_text = physdesc_child.text.lstrip.rstrip
              unless physdesc_child_text.empty?
                physdesc << (physdesc.empty? ? "" : ", ") + physdesc_child_text
              end
            end
          elsif childname == "unitid"
            unitid = did_child.text
          elsif childname == "langmaterial"
            series_langmaterial = get_paragraphs(did_child)
          elsif childname == "origination"
            did_child.children.each do |grandchild|
              if grandchild.name = "persname"
                creator << grandchild.text.strip
              end
            end
          end
        end
      end

      # process the scopecontent element
      paragraphs = get_scopecontent_paragraphs(scopecontent)

      title = (unittitle.empty? ? "" : unittitle + (unitdate.empty? ? "" : ", " + unitdate))
    end

    return title, unittitle, unitdate, unitdate_bulk, creator, physdesc, series_langmaterial, paragraphs, series_arrangement, series_access_restrict, series_use_restrict, series_phystech, series_prefercite, series_processinfo, series_acquisition_info, series_custodhist, series_accruals, series_appraisal, series_separated_material, series_names_and_subjects, series_related_material, series_alt_formats, series_originals_loc, series_other_finding_aids, series_items, unitid
  end


  def get_series_item_info(item, pid)
    title = ""
    paragraphs = []
    labels = ""
    values = ""
    next_level_items = []
    did = nil
    dao = nil
    daogrp = nil
    scopecontent = nil
    unittitle = ""
    unitdate = ""
    physloc = ""
    physloc_orig = ""
    physloc_unprocessed = ""
    creator = ""
    page = ""
    thumbnail = ""
    access_restrict = ""
    available_online = false
    external_page = ""
    external_page_title = ""

    item_id = item.attribute("id").text
    item_url_id = item.attribute("id").text
    item_type = item.attribute("level").text
    item_url = ""

    item.element_children.each do |item_child|
      childname = item_child.name
      if childname == "did"
        did = item_child
      elsif childname == "daogrp"
        daogrp = item_child
      elsif childname == "scopecontent"
        scopecontent = item_child
      elsif childname == "accessrestrict"
        access_restrict = get_paragraphs(item_child).join("  ")  # expecting a string, not an array of paragraphs
      elsif childname == "c03" || childname == "c04" ||
            childname == "c05" || childname == "c06" ||
            childname == "c07" || childname == "c08" ||
            childname == "c09" || childname == "c10" ||
            childname == "c11" || childname == "c12" || childname == "c"
        next_level_items << item_child
      end
    end

    unless did.nil?
      did.element_children.each do |did_child|
        childname = did_child.name
        if childname == "unittitle"
          unittitle = did_child.children.first.text
          did_child.children.each do |grandchild|
            if grandchild.name == "unitdate"
              datetype = grandchild.attribute("type")
              unless !datetype.nil? && datetype.text == "bulk"
                unitdate = grandchild.text
                break
              end
            end
          end
        elsif childname == "unitdate"
          datetype = did_child.attribute("type")
          unless !datetype.nil? && datetype.text == "bulk"
            unitdate = did_child.text
          end
        elsif childname == "unitid"
          # In ASpace EADs the human-readable item id is in <c><did><unitid>... instead of the id attribute of the <c id=...>
          item_id = did_child.text
        elsif childname == "physloc"
          physloc = did_child.text
          physloc_orig = did_child.text
        elsif childname == "container"
          # ASpace puts the location in <container label=""> rather than <physloc>
          unless did_child.attribute("label").nil?
            physloc = did_child.attribute("label").text
            physloc_orig = did_child.attribute("label").text
          end
        elsif childname == "origination"
          did_child.children.each do |grandchild|
            if grandchild.name = "persname"
              creator << grandchild.text.strip
            end
          end
        elsif childname == "dao"
          dao = did_child
        end
      end
    end

    unless physloc.empty?
      # If the location is like: "Mixed Materials (39090015754001g)" or "Mixed Materials [39090015754001g]",
      # remove all but "39090015754001g using regex match"
      physloc_regex = /^(.*?[\(\[])?(.*?)([\)\]])?$/

      if physloc =~ physloc_regex
        physloc = $2
      end

      if physloc_orig =~ physloc_regex
        physloc_orig = $2
      end
    end

    # CIDER EADs have a <daogrp> element.
    unless daogrp.nil?
      daogrp.element_children.each do |daogrp_child|
        if daogrp_child.name == "daoloc"
          daoloc_audience = daogrp_child.attribute("audience")
          daoloc_label = daogrp_child.attribute("label")
          daoloc_href = daogrp_child.attribute("href")

          if !daoloc_audience.nil? && daoloc_audience.text == "internal"
            # an audience="internal" attribute in a daoloc tag means this item is in the Dark Archive;
            # leave page and thumbnail = "" so that values will not be returned for them
            # and so that the href will not be included in title.  Set physloc to the dark
            # archive message.
            physloc = "Dark Archive; <a href=""/contact"">contact DCA</a>"
          elsif !daoloc_label.nil? && !daoloc_href.nil?
            daoloc_label_text = daoloc_label.text
            daoloc_href_text = daoloc_href.text

            if daoloc_label_text == "page"
              page = daoloc_href_text
            elsif daoloc_label_text == "thumbnail"
              thumbnail = daoloc_href_text
            end
          end
        end
      end

      available_online = false
      unless page.empty?
        available_online, f4_id = ingested?(page)
        if available_online
          page = f4_id
          unless thumbnail.empty?
            thumbnail = f4_id
          end
        end
      end
    end

    # ASpace EADs have a <dao> element.
    unless dao.nil?
      dao_href = dao.attribute("href")
      if !dao_href.nil? && dao_href.text.include?("darkarchive")
        # In an ASpace EAD, an href="https://darkarchive.lib.tufts.edu/" attribute in the <dao> element
        # means that this item is in the Dark Archive;  Set physloc to the DA message.
        # Note that if the URL for DA ever changes, all the EADs would not necessarily have to change
        # since the <dao> href value is never displayed or used as a link in TDL.
        physloc = "Dark Archive"
      else
        # ASpace EADs lack the <daogrp><daoloc> page and thumbnail attributes, so compute them from item_id thusly:
        legacy_pid = "tufts:" + item_id
        available_online, f4_id = ingested?(page)

        if available_online
          page = f4_id
          # if page_doc.datastreams.include?("Thumbnail.png")  How do we know if it has a thumbnail or not???
          #   thumbnail = page_pid
          # end
        else
          if dao_href.nil?
            # It's not in Solr, and it's not in darkarchive, and it has no href, so it must be unprocessed.
            physloc_unprocessed = "DCA Digital Storage"
          else
            # It's not in Solr, and it's not in darkarchive, but it has an href, so it must be a non-TDL link.
            external_page = dao_href.text
            available_online = true
            dao_title = dao.attribute("title")
            external_page_title = (dao_title.nil? ? unittitle : dao_title.text)
          end
        end
      end
    end

    if available_online
      if !page.empty?
        item_url = "/concern/tufts_images/" + page               # TBD!!! this might not be an image;  it could be a PDF!
      elsif !external_page.empty?
        item_url = external_page
      end
    elsif item_type == "subseries"
      item_url = finding_aid_series_path(pid, item_url_id)
    end

    title = (item_url.empty? ? "" : "<a " + (external_page.empty? ? "data-turbolinks=\"false\" " : "") + "href=\"" + item_url + "\"" + (external_page.empty? ? "" : " target=\"blank\"") + ">") + unittitle + (unitdate.empty? || (unittitle.end_with?(unitdate))? "" : " " + unitdate) + (item_url.empty? ? "" : "</a>")

    unless physloc.empty?
      labels = "Location:"
      values = physloc
    end

    unless physloc_unprocessed.empty?
      unless labels.empty?
        labels << "<br>"
        values << "<br>"
      end
      labels << "Location:"
      values << physloc_unprocessed
    end

    unless item_id.empty?
      unless labels.empty?
        labels << "<br>"
        values << "<br>"
      end
      labels << "Item ID:"
      values << item_id
    end

    unless item_type.empty?
      unless labels.empty?
        labels << "<br>"
        values << "<br>"
      end
      labels << "Type:"
      values << item_type.capitalize
    end

    unless access_restrict.empty?
      unless labels.empty?
        labels << "<br>"
        values << "<br>"
      end
      labels << "Access:"
      values << access_restrict
    end

    paragraphs = get_scopecontent_paragraphs(scopecontent)

    return unitdate, creator, physloc_orig, access_restrict, item_id, title, paragraphs, labels, values, page, thumbnail, available_online, next_level_items
  end


  def parse_origination(node)
    name = ""
    rcr_url = ""

    first_element = node.first

    unless first_element.nil?
      name = first_element.text
      first_element_id = first_element.attribute("id")

      unless first_element_id.nil?
        rcr_url = first_element_id.text
      end
    end

    return name, rcr_url
  end


end
