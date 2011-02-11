#! /usr/bin/ruby

require 'rubygems'
require 'nokogiri'

include Nokogiri

def each_iteration f
  b = []
  f.each_line do | line |
    b << line
    if line.strip == "</Iteration>"
      yield b
      b = []
    end
  end
end

f = File.open("test/data/nt_example_blastn.m7")
f.each_line do | line |
  break if line.strip == "<Iteration>"
end
each_iteration(f) do | b |
  input = Nokogiri::XML(b.join)

  # input.root.xpath("//Iteration").each do | e |
  e = input.root
    print "---- "
    print e.xpath("Iteration_iter-num/text()"),"\n"
    print e.xpath("Iteration_hits/Hit/Hit_hsps/Hsp/Hsp_score/text()").map {|n| n.to_s}, "\n"

  # end
end


