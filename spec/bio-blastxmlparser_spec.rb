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
    @iter2.iter_num.should == 2
  end
  it "should support Hit fields" do
    hit = @iter1.hits.first
    hit.hit_num.should == 1
    hit.hit_id.should == "lcl|I_74685"
    hit.hit_def.should == "[57809 - 57666] (REVERSE SENSE) "
    hit.accession.should == "I_74685"
    hit.len.should == 144
  end
  it "should iterate Hsps in a hit" do
    hsp = @iter1.hits.first.hsps.first
    hsp.hsp_num.should == 1
    hsp.bit_score.should == 145.205
    hsp.score.should == 73
    hsp.evalue.should == 5.82208e-34
    hsp.query_from.should == 28
    @iter2.iter_num.should == 2
    hits = @iter2.hits.first(3)
    hits.each do | hit |
      p hit
    end
    hsps.each do | hsp |
      p hsp
    end
    hsps[1].bit_score.should == 69.8753
    #           <Hsp_query-from>28</Hsp_query-from>
    #           <Hsp_query-to>100</Hsp_query-to>
    #          <Hsp_hit-from>28</Hsp_hit-from>
    #          <Hsp_hit-to>100</Hsp_hit-to>
    #          <Hsp_query-frame>1</Hsp_query-frame>
    #          <Hsp_hit-frame>1</Hsp_hit-frame>
    #          <Hsp_identity>73</Hsp_identity>
    #          <Hsp_positive>73</Hsp_positive>
    #          <Hsp_align-len>73</Hsp_align-len>
    #          <Hsp_qseq>AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCTGCCTGCCAACCTA
#CTCCTGTGTTTAG</Hsp_qseq>
    #          <Hsp_hseq>AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCTGCCTGCCAACCTA
#CTCCTGTGTTTAG</Hsp_hseq>
    #          <Hsp_midline>|||||||||||||||||||||||||||||||||||||||||||||||||||||

  end
  it "should support Hsp fields"
end

describe Bio::Blast::XmlIterator do
  include Bio::Blast
  it "should parse with Nokogiri"
  it "should parse with Nokogiri and XmlSplitter combined"
end
