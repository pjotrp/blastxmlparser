blastxmlparser is listed at http://biogems.info

# bio-blastxmlparser

blastxmlparser is a very fast big-data BLAST XML file parser, which can be used
as command line utility. Use blastxmlparser to:

* Parse BLAST XML
* Filter output
* Generate FASTA, JSON, YAML, RDF, HTML, tabular output etc.

Rather than loading everything in memory, XML is parsed by BLAST query
(Iteration). Not only has this the advantage of low memory use, it also shows
results early, and it may be faster when IO continues in parallel (disk
read-ahead).

Next to the API, blastxmlparser comes as a command line utility, which
can be used to filter results and requires no understanding of Ruby.

# Quick start

```sh
  gem install bio-blastxmlparser
  blastxmlparser --help
```

(see Installation, below, if it does not work)

## Performance

XML parsing is expensive. blastxmlparser can use the fast Nokogiri C, or
Java XML parsers, based on libxml2. Basically, a DOM parser is used
after splitting the BLAST XML document into subsections.
Tests show this is faster than a SAX
parser with Ruby callbacks.  To see why libxml2 based Nokogiri is
fast, see this
[benchmark](http://www.rubyinside.com/ruby-xml-performance-benchmarks-1641.html)
and [xml.com](http://www.xml.com/lpt/a/1703). 

Blastxmlparser is designed with other optimizations, such as lazy
evaluation, i.e., only creating objects when required, and (in a
future version) parallelization. When parsing a full BLAST result
usually only a few fields are used. By using XPath queries the parser
makes sure only the relevant fields are queried.

Timings for parsing test/data/nt_example_blastn.m7 (file size 3.4Mb) 

```
  bio-blastxmlparser + Nokogiri DOM (default)

  real    0m1.259s
  user    0m1.052s
  sys     0m0.144s

  bio-blastxmlparser + Nokogiri split DOM

  real    0m1.713s
  user    0m1.444s
  sys     0m0.160s

  BioRuby ReXML DOM parser (old style)

  real    1m14.548s
  user    1m13.065s
  sys     0m0.472s
```

## Install

```sh
  gem install bio-blastxmlparser
```

Important: the parser is written for Ruby >= 1.9. Check with

```sh
  ruby -v
  gem env
```

Nokogiri XML parser is required. To install it,
the libxml2 libraries and headers need to be installed first, for
example on Debian:

```sh
  apt-get install libxslt-dev libxml2-dev
  gem install bio-blastxmlparser
```

Nokogiri balks when libxml2 or libxslt is missing on your system (or
may install something automatically). In the worst case you'll have to
provide build paths, as described [here](http://nokogiri.org/tutorials/installing_nokogiri.html).

## Command line usage

### Usage

```
  blastxmlparser [options] file(s)

    -p, --parser name                Use full|split parser (default full)
        --output-fasta               Output FASTA
    -n, --named fields               Set named fields
    -e, --exec filter                Execute filter

        --logger filename            Log to file (default stderr)
        --trace options              Set log level (default INFO, see bio-logger)
    -q, --quiet                      Run quietly
    -v, --verbose                    Run verbosely
        --debug                      Show debug messages
    -h, --help                       Show help and examples

  bioblastxmlparser filename(s)

    Use --help switch for more information
```

### Examples

Print result fields of iterations containing 'lcl', using a regex

```sh
  blastxmlparser -e 'iter.query_id=~/lcl/' test/data/nt_example_blastn.m7
```

prints a tab delimited

```sh
  1       1       lcl|1_0 lcl|I_74685     1       5.82208e-34
  2       1       lcl|1_0 lcl|I_1 1       5.82208e-34
  3       2       lcl|2_0 lcl|I_2 1       6.05436e-59
  4       3       lcl|3_0 lcl|I_3 1       2.03876e-56
```

The second and third column show the BLAST iteration, and the others
relate to the hits.

As this is evaluated Ruby, it is also possible to use the XML element
names directly

```sh
  blastxmlparser -e 'hsp["Hsp_bit-score"].to_i>145' test/data/nt_example_blastn.m7
```

Or the shorter 

```sh
  blastxmlparser -e 'hsp.bit_score>145' test/data/nt_example_blastn.m7
```

And it is possible to print (non default) named fields where E-value < 0.001 
and hit length > 100. E.g.

```sh
  blastxmlparser -n 'hsp.evalue,hsp.qseq' -e 'hsp.evalue<0.01 and hit.len>100' test/data/nt_example_blastn.m7

  1       5.82208e-34     AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCT...
  2       5.82208e-34     AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCT...
  3       2.76378e-11     AATATGGTAGCTACAGAAACGGTAGTACACTCTTC     
  4       1.13373e-13     CTAAACACAGGAGCATATAGGTTGGCAGGCAGGCAAAAT 
  5       2.76378e-11     GAAGAGTGTACTACCGTTTCTGTAGCTACCATATT     
  etc. etc.
```

prints the evalue and qseq columns. To output FASTA use --output-fasta

```sh
  blastxmlparser --output-fasta -e 'hsp.evalue<0.01 and hit.len>100' test/data/nt_example_blastn.m7
```

which prints matching sequences, where the first field is the accession, followed
by query iteration id, and hit_id. E.g.

```sh
  >I_74685 1|lcl|1_0 lcl|I_74685 [57809 - 57666] (REVERSE SENSE) 
  AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCTGCCTGCCAACCTATATGCTCCTGTGTTTAG
  >I_1 1|lcl|1_0 lcl|I_1 [477 - 884] 
  AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCTGCCTGCCAACCTATATGCTCCTGTGTTTAG
  etc. etc.
```

## Modify output

To have more output options blastxmlparser can use an [ERB
template](http://www.stuartellis.eu/articles/erb/) for every match. This is a
very flexible option that can output textual formats such as JSON, YAML, HTML
and RDF. Examples are provided in
[./templates](https://github.com/pjotrp/bioruby-vcf/templates/). A JSON
template could be

```Javascript
{ "<%= hit.parent.query_def %>": {
  "num":      <%= hit.hit_num %>,
  "id":       "<%= hit.hit_id %>",
  "len":      <%= hit.len %>,
  "E-value":  <%= hsp.evalue %>,
  "bitscore": <%= hsp.bit_score %>,
  "qseq":     "<%= hsp.qseq %>",
  "midline":  "<%= hsp.midline %>", 
  "hseq":     "<%= hsp.hseq %>",
};
```

Run it with

```sh
  blastxmlparser --template template/json.erb -e 'hsp.evalue<0.01 and hit.len>100' test/data/nt_example_blastn.m7
```

and get

```Javascript
{ "B0511.9d gene=WBGene00015235": {
  "num":      5,
  "id":       "gi|268566471|ref|XP_002639731.1|",
  "len":      199,
  "E-value":  1.72502e-22,
  "bitscore": 96.6709,
  "qseq":     "MSMLRRPLTQLELSVI------------------VPKCXXXXXXXXXXXXQSEPPRGITRRNLRSADRKNRDVPGPSTGECTRTSIAPNRCEMSFTEVQ-TLTSARTPVAAPTLTLSTPVNPVSSAEMLX----XXXXXXXXXXXASRSGDNDSPLLFNAYDTPQQ--GINXXXXXXXXXXXXXNAHLYAXXXXXXXXXXXXXXXXRSHRH",
  "midline":  "MSMLRRPLTQLEL                       K             QSEP  GI++RNLRSADR+ +DVPG ++GE  +           FT+   +++SARTPV+  ++ LSTPVNP SS EM+                 SR  + D PL+FNAYDTPQQ  G +             NAHLY+                RS RH", 
  "hseq":     "MSMLRRPLTQLELCEDDIQWLSEQLAKKETGFEDEVKYEVMDVDEDEPMDQSEPTGGISKRNLRSADRRKKDVPG-TSGEGAQ-----------FTDQGLSISSARTPVSGASVNLSTPVNPSSSNEMMALPPPVRLARAGRRQRDSRVVNGDVPLMFNAYDTPQQPAGGSNGSPTPSDSPESPNAHLYSTPINPTSSSGGPSSNTRSQRH",
};
```

which I think is pretty good!

## Additional options

To use the low-mem (iterated slower) version of the parser use

  blastxmlparser --parser split -n 'hsp.evalue,hsp.qseq' -e 'hsp.evalue<0.01 and hit.len>100' test/data/nt_example_blastn.m7

## API (Ruby library)

To loop through a BLAST result:

```ruby
    >> require 'bio-blastxmlparser'
    >> fn = 'test/data/nt_example_blastn.m7'
    >>   n = Bio::BlastXMLParser::XmlIterator.new(fn).to_enum
    >>   n.each do | iter |
    >>     puts "Hits for " + iter.query_id
    >>     iter.each do | hit |
    >>       hit.each do | hsp |
    >>         print hit.hit_id, "\t", hsp.evalue, "\n" if hsp.evalue < 0.001
    >>       end
    >>     end
    >>   end
```

The next example parses XML using less memory by using a Ruby
Iterator

```ruby
    >> blast = Bio::BlastXMLParser::XmlSplitterIterator.new(fn).to_enum
    >> iter = blast.next
    >> iter.iter_num
    => 1
    >> iter.query_id
    => "lcl|1_0"
```

Get the first hit

```ruby
    >> hit = iter.hits.first
    >> hit.hit_num
    => 1
    >> hit.hit_id
    => "lcl|I_74685"
    >> hit.hit_def
    => "[57809 - 57666] (REVERSE SENSE) "
    >> hit.accession
    => "I_74685"
    >> hit.len
    => 144
```

Get the parent info

```ruby
    >> hit.parent.query_id
    => "lcl|1_0"
```

Get the first Hsp

```ruby
    >> hsp = hit.hsps.first
    >> hsp.hsp_num
    => 1
    >> hsp.bit_score
    => 145.205
    >> hsp.score
    => 73
    >> hsp.evalue
    => 5.82208e-34
    >> hsp.query_from
    => 28
    >> hsp.query_to
    => 100
    >> hsp.query_frame
    => 1
    >> hsp.hit_frame
    => 1
    >> hsp.identity
    => 73
    >> hsp.positive
    => 73
    >> hsp.align_len
    => 73
    >> hsp.qseq
    => "AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCTGCCTGCCAACCTATATGCTCCTGTGTTTAG"
    >> hsp.hseq
    => "AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCTGCCTGCCAACCTATATGCTCCTGTGTTTAG"
    >> hsp.midline
    => "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
```

Unlike BioRuby, this module uses the actual element names in the XML
definition, to avoid confusion (if anyone wants a translation,
feel free to contribute an adaptor).

It is also possible to use the XML element names as Strings, rather
than methods. E.g.

```ruby
    >> hsp.field("Hsp_bit-score")
    => "145.205"
    >> hsp["Hsp_bit-score"]
    => "145.205"
```

Note that, when using the element names, the results are always String values.

Fetch the next result (Iteration)

```ruby
    >> iter2 = blast.next
    >> iter2.iter_num
    >> 2 
    >> iter2.query_id
    => "lcl|2_0"
```

etc. etc.

For more examples see the files in ./spec

## URL

The project lives at http://github.com/pjotrp/blastxmlparser. If you use this software, please cite http://dx.doi.org/10.1093/bioinformatics/btq475

## Copyright

Copyright (c) 2011-2014 Pjotr Prins under the MIT licence.  See LICENSE.txt and http://www.opensource.org/licenses/mit-license.html for further details.

