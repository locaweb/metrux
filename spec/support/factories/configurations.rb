FactoryGirl.define do
  factory :configuration, class: Metrux::Configuration  do
    config_path File.expand_path('spec/support/config/metrux.yml')

    initialize_with { new(config_path).dup }
  end
end
