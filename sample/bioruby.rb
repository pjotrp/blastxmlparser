#!/usr/bin/env ruby
require 'bio'

fn = 'test/data/nt_example_blastn.m7'

# Iterates over each XML result.
# The variable "report" is a Bio::Blast::Report object.
# Bio::Blast.reports(ARGF) do |report| 
Bio::Blast.reports(File.new(fn)) do |report| 
  print "hey\n"
  puts "Hits for " + report.query_def + " against " + report.db
  report.each do |hit|
    print hit.target_id, "\t", hit.evalue, "\n" if hit.evalue < 0.001
  end
end
