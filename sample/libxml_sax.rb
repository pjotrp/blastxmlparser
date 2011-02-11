#! /usr/bin/ruby

require 'rubygems'
require 'libxml'

include LibXML

class PostCallbacks
  include XML::SaxParser::Callbacks

  def on_start_element(element, attributes)
    if element == 'Iteration_iter-num'
      # Process row of data here
      print "---- ",element
    end
    # if element == 'Hsp_score'
    #   print "---- ",element
    # end
  end
end

parser = XML::SaxParser.file("test/data/nt_example_blastn.m7")
parser.callbacks = PostCallbacks.new
parser.parse

