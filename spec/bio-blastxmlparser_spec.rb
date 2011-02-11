require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Bio::Blast::XmlSplitter do
  include Bio::Blast
  it "should read a large file and yield Iterations" do
    s = XmlSplitter.new("./test/data/nt_example_blastn.m7")
    s.each do | result |
      result[1].to_s.should =~ /Iteration_iter-num/
    end
  end
end

describe "Bio::Blast::NokogiriBlast" do
  include Bio::Blast
  it "should return Iteration info"
  it "should iterate Hsps"
  it "should support Hsp fields"
end

describe Bio::Blast::XmlIterator do
  include Bio::Blast
  it "should parse with Nokogiri" do
  end
end
