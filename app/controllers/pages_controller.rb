class PagesController < ApplicationController
  include HighVoltage::StaticPage

  # without including this it doesn't load the curation_concerns layout 
  # because of the missing current_search_session
  include Blacklight::SearchContext
end
