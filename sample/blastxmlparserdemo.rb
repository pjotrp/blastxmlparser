#! /usr/bin/ruby

rootpath = File.dirname(File.dirname(__FILE__))
$: << File.join(rootpath,'lib')

require 'bio-blastxmlparser'
fn = 'test/data/nt_example_blastn.m7'
n = Bio::BlastXMLParser::XmlIterator.new(fn).to_enum
n.each do | iter |
  puts "Hits for " + iter.query_id
  iter.each do | hit |
    hit.each do | hsp |
      print hit.hit_id, "\t", hsp.evalue, "\n" if hsp.evalue < 0.001
    end
  end
end

