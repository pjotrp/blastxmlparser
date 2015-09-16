# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bio-blastxmlparser"
  s.version = "2.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pjotr Prins"]
  s.date = "2015-05-07"
  s.description = "Fast big data BLAST XML parser and library; this libxml2 based version is 50x faster than BioRuby and comes with a nice CLI"
  s.email = "pjotr.public01@thebird.nl"
  s.executables = ["blastxmlparser"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".travis.yml",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/blastxmlparser",
    "bio-blastxmlparser.gemspec",
    "lib/bio-blastxmlparser.rb",
    "lib/bio/db/blast/parser/nokogiri.rb",
    "lib/bio/db/blast/xmliterator.rb",
    "lib/bio/db/blast/xmlsplitter.rb",
    "lib/bio/writers/rdf.rb",
    "lib/bio/writers/template.rb",
    "sample/bioruby.rb",
    "sample/blastxmlparserdemo.rb",
    "sample/libxml_sax.rb",
    "sample/nokogiri_dom.rb",
    "sample/nokogiri_sax.rb",
    "sample/nokogiri_split_dom.rb",
    "spec/bio-blastxmlparser_spec.rb",
    "spec/spec_helper.rb",
    "template/blast2json.erb",
    "template/blast2json2.erb",
    "template/blast2rdf-minimal.erb",
    "template/blast2rdf.erb",
    "test/data/aa_example.fasta",
    "test/data/aa_example_blastp.m7",
    "test/data/nt_example.fasta",
    "test/data/nt_example_blastn.m7",
    "timings.sh"
  ]
  s.homepage = "http://github.com/pjotrp/blastxmlparser"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.summary = "Very fast parallel BLAST XML to RDF/HTML/JSON/YAML/csv transformer"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bio-logger>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<bio-logger>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<bio-logger>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end

