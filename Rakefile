# encoding: UTF-8
require 'rubygems'
require 'rails'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'solr_wrapper'
require 'fcrepo_wrapper'
require 'active_fedora/rake_support'
require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
end

RSpec::Core::RakeTask.new(:spec)

desc 'Spin up test servers and run specs'
task :spec_with_app_load do
  with_test_server do
    Rake::Task['spec'].invoke
  end
end

desc 'Generate the engine_cart and spin up test servers and run specs'
task :ci do
  ENV['environment'] = "test"
  puts 'running continuous integration'
  Rake::Task['spec_with_app_load'].invoke
end
task :default => []; Rake::Task[:default].clear
task :default => [:ci]
