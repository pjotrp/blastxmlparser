require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Bio::Blast::XmlSplitter do
  include Bio::Blast
  it "should read a large file and yield Iterations" do
    p = XmlSplitter.new("./test/data/nt_example_blastn.m7")
    p.each do | result |
      result[1].to_s.should =~ /Iteration_iter-num/
    end
  end
end
