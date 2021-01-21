require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'fileutils'
include FileUtils

NAME = "mk4rb"
VERS = "0.1"
CLEAN.include ['ext/metakit_raw/*.{bundle,so,obj,pdb,lib,def,exp}', 'ext/metakit_raw/Makefile', 
               '**/.*.sw?', '*.gem', '.config']

desc "Does a full compile, test run"
task :default => [:compile, :test]

desc "Compiles all extensions"
task :compile => [:metakit_raw] do
  if Dir.glob(File.join("lib","metakit_raw.*")).length == 0
    STDERR.puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    STDERR.puts "Gem actually failed to build.  Your system is"
    STDERR.puts "NOT configured properly to build mk4rb."
    STDERR.puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit(1)
  end
end

desc "Packages up mk4rb."
task :package => [:clean]

desc "Run all the tests"
Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/*_test.rb']
    t.verbose = true
end

spec =
    Gem::Specification.new do |s|
        s.name = NAME
        s.version = VERS
        s.platform = Gem::Platform::RUBY
        s.has_rdoc = false
        s.summary = "ruby bindings for Metakit"
        s.description = s.summary
        s.author = "Ed Sinjiashvili"

        s.files = %w(Rakefile) +
          Dir.glob("{bin,doc,test,lib,extras}/**/*") + 
          Dir.glob("ext/**/*.{h,inl,lib,cpp,rb}")    
        
        s.require_path = "lib"
        s.autorequire = "mk4rb"
        s.extensions = FileList["ext/**/extconf.rb"].to_a #unless RUBY_PLATFORM =~ /mswin/
        s.bindir = "bin"
    end

Rake::GemPackageTask.new(spec) do |p|
    p.need_tar = false
    p.gem_spec = spec
end

extension = "metakit_raw"
ext = "ext/metakit_raw"
ext_so = "#{ext}/#{extension}.#{Config::CONFIG['DLEXT']}"
ext_files = FileList[
  "#{ext}/*.cpp",
  "#{ext}/*.h",
  "#{ext}/extconf.rb",
  "#{ext}/Makefile",
  "lib"
] 

task "lib" do
  directory "lib"
end

desc "Builds just the #{extension} extension"
task extension.to_sym => ["#{ext}/Makefile", ext_so ]

file "#{ext}/Makefile" => ["#{ext}/extconf.rb"] do
  Dir.chdir(ext) do ruby "extconf.rb" end
end

file ext_so => ext_files do
  Dir.chdir(ext) do
    sh(PLATFORM =~ /win32/ ? 'nmake' : 'make')
  end
  cp ext_so, "lib"
end

task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{NAME}-#{VERS}}
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end
