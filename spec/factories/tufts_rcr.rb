FactoryGirl.define do
  factory :tufts_RCR00579_rcr, class: TuftsRcr do
    transient do
      user { FactoryGirl.create(:user) }  # find_or_create ???
    end
    id { 's4655g578' }
    title { ["Tisch Library"] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    before(:create) do |work, evaluator|
      work.ordered_members << FactoryGirl.create(:file_set, user: evaluator.user, title: ['A Contained FileSet'])
    end

    after(:create) do |work, evaluator|
      rcr_test_file_1 = File.open(File.expand_path(File.join("#{Rails.root}", "spec", "fixtures", "RCR00579.xml")))
      original_file = work.file_sets[0].build_original_file
      original_file.content = rcr_test_file_1
      work.file_sets[0].save
      work.save
    end
  end

end
