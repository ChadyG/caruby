spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "caruby"
    s.version   =   "1.0.1"
    s.author    =   "Chad Godsey"
    s.email     =   "LyleBarbatuous@gmail.com"
    s.summary   =   "A package for creating and deploying Cellular Automaton"
    s.files     =   FileList['lib/*.rb', 'test/*'].to_a
    s.autorequire = 'lib/caruby.rb'
    s.has_rdoc  =   true
    s.extra_rdoc_files  =   ["README", "COPYING"]
end
