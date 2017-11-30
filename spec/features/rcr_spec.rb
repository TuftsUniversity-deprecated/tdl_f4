require 'rails_helper'
i_need_ldap

feature 'RCR' do
  include TestHelpers

  before do
    FactoryGirl.create(:tufts_RCR00579_rcr)
  end

 scenario 'View RCR00579 ("Tisch Library") page' do
   visit '/concern/tufts_rcrs/s4655g578'
    page.should have_text 'Tisch Library, 1996-present'
    page.should have_text 'The Tisch Library (1860-present) opened in 1996, as the main Arts, Sciences, and Engineering library at Tufts University, made possible by a generous donation from the Tisch family.'
    page.should have_text 'History of Tisch Library'
    page.should have_text 'The Tisch Library (1860-present) opened in 1996, as one of the Arts, Sciences, and Engineering libraries at Tufts University, made possible by a generous donation from the Tisch family.'
    page.should have_text 'The library currently houses the collection for the Arts, Sciences and Engineering departments.'
    page.should have_text 'List of head librarians for Eaton/Wessell/Tisch Library:'
    page.should have_text 'President Hosea Ballou (prior to 1861/1862 academic year)'
    page.should have_text 'Laura Wood'
    page.should have_text 'Collections'
    page.should have_text 'Tufts Libraries'
    page.should have_text 'Tisch Library, records'
    page.should have_text 'Arts and Sciences Library(Wessell/Tisch), records'
    page.should have_text 'Relationships'
    page.should have_text 'Part of:'
    page.should have_text 'Tufts University (1996-present)'
    page.should have_text 'School of Arts and Sciences (1996-present)'
    page.should have_text 'Associated with:'
    page.should have_text 'Tisch, Jonathan Mark (1996-present)'
    page.should have_text 'University Library Council (2002-present)'
    page.should have_text 'Preceded by:'
    page.should have_text 'Eaton Library (1908-1965)'
    page.should have_text 'Wessell Library (1965-1996)'
 end

end
