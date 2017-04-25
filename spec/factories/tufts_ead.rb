FactoryGirl.define do
  factory :tufts_MS999_ead, class: TuftsEad do
    transient do
      user { FactoryGirl.create(:user) }  # find_or_create ???
    end
    id {'ks65hc20t'}
    title {["Lorem Ipsum papers"] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    before(:create) do |work, evaluator|
      work.ordered_members << FactoryGirl.create(:file_set, user: evaluator.user, title: ['A Contained FileSet'])
    end  

    after(:create) do |work, evaluator|
      ead_test_file_1 = File.open(File.expand_path(File.join("#{Rails.root}", "spec", "fixtures", "MS999.archival.xml")))
      original_file = work.file_sets[0].build_original_file
      original_file.content = ead_test_file_1
      work.file_sets[0].save
      work.save
    end
  end  

  factory :tufts_MS226_ead, class: TuftsEad do
    transient do
      user { FactoryGirl.create(:user) }  # find_or_create ???
    end
    id {'p2676v52c'}
    title {['Rubin "Hurricane" Carter papers'] }
    displays_in { ['dl'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    before(:create) do |work, evaluator|
      work.ordered_members << FactoryGirl.create(:file_set, user: evaluator.user, title: ['A Contained FileSet'])
    end  

    after(:create) do |work, evaluator|
      ead_test_file_1 = File.open(File.expand_path(File.join("#{Rails.root}", "spec", "fixtures", "MS226.archival.xml")))
      original_file = work.file_sets[0].build_original_file
      original_file.content = ead_test_file_1
      work.file_sets[0].save
      work.save
    end
  end  

end
