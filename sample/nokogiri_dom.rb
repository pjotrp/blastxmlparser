#! /usr/bin/ruby

require 'rubygems'
require 'nokogiri'

include Nokogiri

input = Nokogiri::XML(File.new("test/data/nt_example_blastn.m7"))

input.root.xpath("//Iteration").each do | e |
  print "---- "
  print e.xpath("Iteration_iter-num/text()"),"\n"
  print e.xpath("Iteration_hits/Hit/Hit_hsps/Hsp/Hsp_score/text()").map {|n| n.to_s}, "\n"

end


