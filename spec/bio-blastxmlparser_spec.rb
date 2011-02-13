require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

TESTFILE = "./test/data/nt_example_blastn.m7"

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
  it "should support Hit parent" do
    hit = @iter1.hits.first
    hit.parent.should == @iter1
    hit.parent.query_id.should == "lcl|1_0"
  end

  it "should support Hsps" do
    hsp = @iter1.hits.first.hsps.first
    hsp.hsp_num.should == 1
    hsp.bit_score.should == 145.205
    hsp.score.should == 73
    hsp.evalue.should == 5.82208e-34
    hsp.query_from.should == 28
    hsp.query_to.should == 100
    hsp.query_frame.should == 1
    hsp.hit_frame.should == 1
    hsp.identity.should == 73
    hsp.positive.should == 73
    hsp.align_len.should == 73
    hsp.qseq.should == "AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCTGCCTGCCAACCTATATGCTCCTGTGTTTAG"
    hsp.hseq.should == "AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCTGCCTGCCAACCTATATGCTCCTGTGTTTAG"
    hsp.midline.should == "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    @iter2.iter_num.should == 2
    hits = @iter2.hits.first(3)
    hits.map { | h | h.hit_num }.should == [1,2,3]
    hsps = hits[1].hsps
    hsps.map { | hsp | hsp.hsp_num }.should == [1]
    hsps.first.bit_score.should == 109.522
  end
  it "should support Hsp parent" do
    hsp = @iter1.hits.first.hsps.first
    hsp.parent.hit_id.should == "lcl|I_74685"
  end

  it "should support Hit XML fields" do
    hit = @iter1.hits.first
    hit.hit_num.should == 1
    hit["Hit_id"].should == "lcl|I_74685"
  end
  it "should support Hsp XML fields" do
    hsp = @iter1.hits.first.hsps.first
    hsp.hsp_num.should == 1
    hsp.bit_score.should == 145.205
    hsp.field("Hsp_bit-score").should == "145.205"
    hsp["Hsp_bit-score"].should == "145.205"
    # later: hsp["bit-score"].should == "145.205"
    hsp["Hsp_hseq"].should == "AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCTGCCTGCCAACCTATATGCTCCTGTGTTTAG"
  end
end

describe Bio::Blast::XmlIterator do
  include Bio::Blast
  it "should parse with Nokogiri" do
    blast = XmlIterator.new(TESTFILE).to_enum
    iter1 = blast.next
    iter1.query_id.should == "lcl|1_0"
    iter2 = blast.next
    iter2.query_id.should == "lcl|2_0"
  end
end

describe Bio::Blast::XmlSplitterIterator do
  include Bio::Blast
  # it "should read a large file and yield Iterations" do
  #   s = XmlSplitter.new("./test/data/nt_example_blastn.m7")
  #   s.each do | result |
  #     result[1].to_s.should =~ /Iteration_iter-num/
  #   end
  # end

  it "should parse with Nokogiri and XmlSplitter combined" do
    blast = XmlSplitterIterator.new(TESTFILE).to_enum
    iter1 = blast.next
    print iter1.to_s
    iter2 = blast.next
    print iter2.to_s
    iter1.query_id.should == "lcl|1_0"
    iter2.query_id.should == "lcl|2_0"
  end
end
