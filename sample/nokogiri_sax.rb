#! /usr/bin/ruby

require 'rubygems'
require 'nokogiri'

include Nokogiri

class PostCallbacks < XML::SAX::Document
  def start_element(element, attributes)
    if element == 'row'
      # Process row of data here
    end
  end
end

parser = XML::SAX::Parser.new(PostCallbacks.new)
parser.parse_file("test/data/nt_example_blastn.m7")

