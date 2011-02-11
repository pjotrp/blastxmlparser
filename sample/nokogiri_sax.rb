#! /usr/bin/ruby

require 'rubygems'
require 'nokogiri'

include Nokogiri

   #   print "---- "
   #   print e.xpath("Iteration_iter-num/text()"),"\n"
   #   print e.xpath("Iteration_hits/Hit/Hit_hsps/Hsp/Hsp_score/text()").map {|n| n.to_s}, "\n"

class PostCallbacks < XML::SAX::Document
  def start_element(element, attributes)
    if element == 'Iteration_iter-num'
      # Process row of data here
      print "---- ",element
    end
    if element == 'Hsp_score'
      print "---- ",element
    end
  end
end

parser = XML::SAX::Parser.new(PostCallbacks.new)
parser.parse_file("test/data/nt_example_blastn.m7")

