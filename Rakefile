require "bundler/gem_tasks"

# Create the spec task.
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:test, :tag) do |t, args|
  t.rspec_opts = [].tap do |a|
    a << "--color"
    a << "--format #{ENV["CI"] ? "documentation" : "progress"}"
    a << "--backtrace" if ENV["VERBOSE"] || ENV["DEBUG"]
    a << "--seed #{ENV["SEED"]}" if ENV["SEED"]
    a << "--tag #{args[:tag]}" if args[:tag]
    a << "--default-path test"
    a << "-I test/spec"
  end.join(" ")
end

begin
  require "yard"

  # Options and the file list live in .yardopts so that a bare `yard` from the
  # command line produces exactly what `rake doc` does.
  YARD::Rake::YardocTask.new(:doc)

  desc "List anything in lib/ that is still undocumented"
  task :doc_coverage do
    sh "yard stats --list-undoc"
  end
rescue LoadError
  desc "Generate YARD documentation (not installed)"
  task :doc do
    abort "YARD is not installed. Run: bundle install"
  end
end
