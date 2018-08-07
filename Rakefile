namespace :style do
  require 'cookstyle'
  require 'rubocop/rake_task'
  desc 'Run Ruby style checks using rubocop'
  RuboCop::RakeTask.new(:ruby)

  require 'foodcritic'
  desc 'Run Chef style checks using foodcritic'
  FoodCritic::Rake::LintTask.new(:chef)
end

desc 'Run all style checks'
task style: %w(style:chef style:ruby)

desc 'Run ChefSpec unit tests'
task :unit do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.rspec_opts = '--color --format progress'
    t.pattern = 'spec/**{,/*/**}/*_spec.rb'
  end
end

desc 'Run Test Kitchen integration tests'
begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
  task integration: 'kitchen:all'
end

desc 'Run style and unit tests'
task default: %w(style unit integration)
