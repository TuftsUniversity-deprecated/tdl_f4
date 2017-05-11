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
    page.should have_text 'Lorem Ipsum papers'
    page.should have_text 'This collection has:'
    page.should have_text '585 Cubic Feet'
    page.should have_text '487 record cartons and 1 document case'
    page.should have_text '197 Gigabytes'
    page.should have_text '95 Cassettes'
    page.should have_text 'The papers of Lorem Ipsum, noted scholar and salon host, consist of his personal and professional papers, including a wide range of correspondence with noted thinkers, scholars, and chorus girls of the 1910s and 1920s.'
    page.should_not have_text 'View Online Materials'
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
