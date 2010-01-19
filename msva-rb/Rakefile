# -*- ruby -*-

begin
  require 'rubygems'
rescue LoadError
  $stderr.puts "no rubygems. no guarantees of success."
end

require 'rake'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = ["--color", "--format nested"]
  t.spec_files = FileList['spec/**_spec.rb']
end
