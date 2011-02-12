require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

TESTFILE = "./test/data/nt_example_blastn.m7"
describe Bio::Blast::XmlSplitter do
  include Bio::Blast
  it "should read a large file and yield Iterations" do
    s = XmlSplitter.new("./test/data/nt_example_blastn.m7")
    s.each do | result |
      result[1].to_s.should =~ /Iteration_iter-num/
    end
  end
end

describe "Bio::Blast::NokogiriBlastXml" do
  include Bio::Blast
  before(:all) do
    n = NokogiriBlastXml.new(File.new(TESTFILE)).to_enum
    @iter1 = n.next
    @iter2 = n.next
  end
  it "should return Iteration header fields" do
    @iter1.iter_num.should == 1
    @iter1.query_id.should == "lcl|1_0"
    @iter1.query_def.should == "I_1 [477 - 884] "
    @iter1.query_len.should == 408
  end
  it "should support Hit fields" do
    hit = @iter1.first
    hit.num.should == 1
    hit.id.should == "lcl|I_74685"
    hit.def.should == "[57809 - 57666] (REVERSE SENSE) "
    hit.accession.should == "I_74685"
    hit.len.should == 144
  end
  it "should iterate Hsps in a hit"
  it "should support Hsp fields"
end

describe Bio::Blast::XmlIterator do
  include Bio::Blast
  it "should parse with Nokogiri"
  it "should parse with Nokogiri and XmlSplitter combined"
end
