require 'rails_helper'
i_need_ldap

feature 'EAD' do
  include TestHelpers

  before do
 #   @ead1 = TuftsEad.find('tufts:UA069.001.DO.UA015')  # ACCION International records
 #   @ead2 = TuftsEad.find('tufts:MS999')               # Lorem Ipsum papers ("kitchen sink EAD")
    FactoryGirl.create(:tufts_MS999_ead)
    FactoryGirl.create(:tufts_MS226_ead)
  end

# scenario 'View ACCION landing page' do
#   visit '/concern/tufts_eads/ks65hc20t'
#    page.should have_text 'ACCION International records'
#    page.should have_text 'This collection has:'
#    page.should have_text '62.40 cubic ft., 238 audio-visual media, 410 digital objects'
#    page.should have_text 'ACCION International was founded in 1961 by Joseph H. Blatchford.'
# end

 scenario 'View MS999 ("kitchen sink") landing page' do
   visit '/concern/tufts_eads/ks65hc20t'
    page.should have_text 'Lorem Ipsum papers, 1897 -- 1933'
    page.should have_text 'This collection has:'
    page.should have_text '585 Cubic Feet'
    page.should have_text '487 record cartons and 1 document case'
    page.should have_text '197 Gigabytes'
    page.should have_text '95 Cassettes'
    page.should have_text 'The papers of Lorem Ipsum, noted scholar and salon host, consist of his personal and professional papers, including a wide range of correspondence with noted thinkers, scholars, and chorus girls of the 1910s and 1920s.'
#   page.should_not have_text 'View Online Materials'

    click_link "View Finding Aid", :exact => false
    page.should have_text "Lorem Ipsum papers, 1897-1933"
    page.should have_text "Title: Lorem Ipsum papers"
    page.should have_text "Dates: 1897 -- 1933"
    page.should have_text "Bulk Dates: 1910 -- 1933"
    page.should have_text "Creator: Ipsum, Lorem, 1850-1933"
    page.should have_text "Call Number: MS999"
    page.should have_text "Size: 585 Cubic Feet, 487 record cartons and 1 document case, 197 Gigabytes, 95 Cassettes"
    page.should have_text "Language(s): Materials are in English, French, and Russian."
    page.should have_text "Permanent URL: http://hdl.handle.net/fake/false"
    page.should have_text "Location:"
    page.should have_text "Digital Collections and Archives, Tufts University "
    page.should have_text "archives@tufts.edu"
    page.should have_text "http://sites.tufts.edu/dca/"
    page.should have_text "The Lorem Ipsum papers consist of his personal and professional papers."
    page.should have_text "Diaries cover the years 1910-1933 with a suspicious gap in 1922."
    page.should have_text "This collection is arranged in two series."
    page.should have_text "Lorem Ipsum was born in Peoria, Illinois, in 1850."
    page.should have_text "Open to research."
    page.should have_text "Copyright has been retained by donor. Researchers are responsible for contacting copyright holders."
    page.should have_text "This collection has no technical requirements for access."
    page.should have_text "Lorem Ipsum papers, 1897-1933. Tufts University. Digital Collections and Archives. Medford, MA."
    page.should have_text "Processed in 2016 by Samantha Redgrave."
    page.should have_text "Gift of Harold Lloyd III, 2016."
    page.should have_text "Although Ipsum's rare books were safely ensconced at Oberlin,"
    page.should have_text "No further accruals are expected."
    page.should have_text "Duplicate materials were discaded during processing, as was Mr. Ipsum's rather careworn feather boa."
    page.should have_text "Taxidermy originally in this collection has been transferred to the natural history museum."
    page.should have_text "Processing funded by a generous grant from NEH, 2015."
    page.should have_text "University of Chicago"
    page.should have_text "Adolescence"
    page.should have_text "Advertising"
    page.should have_text "Medford (Mass.)"
    page.should have_text "Lorem Ipsum rare book collection, Cornell University."
    page.should have_text "Lorem Ipsum faculty papers, University of Chicago."
    page.should have_text "This collection is also available on microfilm."
    page.should have_text "Some letters in the correspondence series are photocopies; originals reside with the original authors."
    page.should have_text "A detailed item level list with transcriptions of diaries and letters is available in the repository."
    page.should have_text "Personal papers, 1900 -- 1933"
    page.should have_text "Personal papers consist largely of correspondence and diaries."
    page.should have_text "1.1. Correspondence, 1900 -- 1933"
    page.should have_text "Correspondence with many leading lights of the day,"
    page.should have_text "1.2. Diaries, 1910 -- 1933"
    page.should have_text "Diaries are salacious and gossipy."
    page.should have_text "Professional papers, 1897 -- 1933"
    page.should have_text "Professional papers consists of manuscripts, speeches, notes, and student papers."
    page.should have_text "Speeches are very dull."

    click_link "Personal papers, 1900 -- 1933", :exact => false
    page.should have_text "Personal papers, 1900 -- 1933"
    page.should have_text "This series is part of Lorem Ipsum papers, 1897 -- 1933"
    page.should have_text "Title: Personal papers "
    page.should have_text "Dates: 1900 -- 1933"
    page.should have_text "Bulk Dates: 1910 -- 1933"
    page.should have_text "Call Number: MS999.001"
    page.should have_text "Size: 68 Cubic Feet, 56 record cartons and 2 document cases, 22 Volumes"
    page.should have_text "Language(s): Materials in this series are in English and French."
    page.should have_text "Personal papers consist largely of correspondence and diaries."
    page.should have_text "This series is organized in two subseries."
    page.should have_text "Open for research."
    page.should have_text "Copyright retained by donor."
    page.should have_text "This series has no technical requirements for access."
    page.should have_text "Personal papers, Lorem Ipsum papers, 1897-1933. Tufts University. Digital Collections and Archives. Medford, MA."
    page.should have_text "Evidence suggests that the original processor of this collection may have actually ingested the contents of an envelope marked \"Illegal Fungi,\" which we have been otherwise unable to locate."
    page.should have_text "Gift of Harold Lloyd III, 2016."
    page.should have_text "Upon his death, Ipsum's personal papers were discarded by an unfeeling landlady. They were rescued by a fellow scholar and maintained in a personal collection until they were donated to Tufts University in 2016."
    page.should have_text "No further accruals are expected."
    page.should have_text "Duplicate materials were discaded during processing, as was Mr. Ipsum's rather careworn feather boa."
    page.should have_text "Silk stockings found in this series have been transferred to the Textile Museum."
    page.should have_text "Letters (correspondence)"
    page.should have_text "Lorem Ipsum rare book collection, Cornell University."
    page.should have_text "Lorem Ipsum faculty papers, University of Chicago."
    page.should have_text "This series is also available on graven tablets."
    page.should have_text "Some letters in the correspondence series are photocopies; originals reside with the original authors."
    page.should have_text "A detailed item level list with transcriptions of diaries and letters is available in the repository."
    page.should have_text "Correspondence 1900 -- 1933"
    page.should have_text "Correspondence with many leading lights of the day, including H. L. Mencken, F. Scott and Zelda Fitzgerald, William James, and Louise Brooks, among others."
    page.should have_text "MS999.001.001"
    page.should have_text "Diaries 1910 -- 1933"
    page.should have_text "Diaries are salacious and gossipy."
    page.should have_text "MS999.001.002"
    page.should have_text "There is also Lorem Ipsum material to be found online. Please visit https://somerandomwebsite.org/collections/LoremIpsum and/or The Lorem Ipsum Collection at someotherrandomwebsite.org."
    page.should have_text "New Yorker Cartoons 1922-12-09 - 1927-03-09"
  end

 scenario 'View MS226 (Rubin Carter papers) landing page' do
   visit '/concern/tufts_eads/p2676v52c'
    page.should have_text 'Rubin "Hurricane" Carter papers'
    page.should have_text 'This collection has:'
    page.should have_text '21.6 Cubic Feet'
    page.should have_text '6 Digital Object(s)'
    page.should have_text 'Rubin Carter was born on May 6, 1937, in Clifton, New Jersey, to Lloyd and Bertha Carter.'
#    page.should have_text 'View Online Materials'
 end

#  scenario 'View Online Materials should link to associated materials in search results' do
#    visit catalog_path(@ead)
#    click_link 'View Online Materials', :exact => false
#    page.should have_text 'Alliance for Progress or Alianza Para El Progreso? A Reassessment of the Latin American Contribution to the Alliance for Progress'
#  end

#  scenario 'from the Finding Aid Viewer, View Online Materials should link to associated materials in search results' do
#    visit catalog_path(@ead)
#    click_link 'View Finding Aid', :exact => false
#    click_link 'View Online Materials', :exact => false
#    page.should have_text 'Alliance for Progress or Alianza Para El Progreso? A Reassessment of the Latin American Contribution to the Alliance for Progress'
#  end

#  scenario 'MS999 (kitchen sink ASpace EAD) should have a View Finding Aid link;  series should contain items' do
#    visit catalog_path(@aspace_ead)

#    click_link 'View Finding Aid', :exact => false
#    page.should have_text 'Lorem Ipsum papers, 1897-1933'
#    page.should have_text 'Title: Lorem Ipsum papers'

#    click_link 'Personal papers, 1900 -- 1933', :exact => false
#    page.should have_text 'Personal papers, 1900 -- 1933'
#    page.should have_text 'This series is part of Lorem Ipsum papers, 1897 -- 1933'
#  end
end
