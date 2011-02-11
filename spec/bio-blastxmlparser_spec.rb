require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Bio::Blast::XmlBulkParser do
  include Bio::Blast
  it "should read a large file and yield Iterations" do
    p = XmlBulkParser.new("./test/data/nt_example_blastn.m7")
    p.each do | result |
    end
  end
end
