require 'rails_helper'

describe ApplicationHelper do
  describe "model_partial_registry" do
    models = {
      "Image" => "image",
      "Ead" => "ead",
      "VotingRecord" => "voting_record",
    }

    it "provides the appropriate partial for each model" do
      models.each do |model, view|
        partial = helper.model_partial_registry("Tufts#{model}")
        expect(partial).to eq("curation_concerns/tufts_#{view}s/show_#{view}")
      end
    end

    it "provides curation concerns partial for unmatched model" do
      partial = helper.model_partial_registry("SomethingWeird")
      expect(partial).to eq('curation_concerns/base/show_curation_concern')
    end

  end
end

