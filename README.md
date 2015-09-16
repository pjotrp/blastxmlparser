[![Build Status](https://travis-ci.org/pjotrp/blastxmlparser.svg?branch=master)](https://travis-ci.org/pjotrp/blastxmlparser)

# bio-blastxmlparser

blastxmlparser is a very fast parallel big-data BLAST XML file
parser, which can be used as command line utility. Use blastxmlparser
to:

* Parse BLAST XML
* Filter output
* Generate FASTA, JSON, YAML, RDF, JSON-LD, HTML, csv, tabular output etc. 

Rather than loading everything in memory, XML is parsed by BLAST query
(Iteration). Not only has this the advantage of low memory use, it also shows
results early, and it is faster when IO continues in parallel (disk
read-ahead).

blastxmlparser comes as a command line utility, which
can be used to filter results and requires no understanding of Ruby.

# Quick start

```sh
  gem install bio-blastxmlparser
  gem install parallel # if you want multi-core support
  blastxmlparser --help
```

## Performance

XML parsing and transformation is expensive. blastxmlparser can use
the fast Nokogiri C, or Java XML parsers, based on libxml2 in
parallel. A DOM parser is used after splitting the BLAST XML document
into subsections.  Tests show this is faster than a SAX parser with
Ruby callbacks.  To see why libxml2 based Nokogiri is fast, see
[xml.com](http://www.xml.com/lpt/a/1703). And blastxmlparser uses 
Nokogiri in parallel.

Blastxmlparser is designed with other optimizations, such as lazy
evaluation, i.e., only creating objects when required. When parsing a
full BLAST result usually only a few fields are used. By using XPath
queries the parser makes sure only the relevant fields are queried.

Timings for parsing a 1 Gb BLAST XML file on 4-core 1.2GHz laptop 

```
  real    2m40.248s
  user    8m11.075s
  sys     0m37.198s
```

which makes for pretty good core utilisation and limited RAM use. If
you have enough RAM it may make sense to try the `--parser nosplit'
option which starts by reading the full DOM into RAM. It may be faster
and show different IO characteristics.

## Install

```sh
  gem install parallel bio-blastxmlparser
```

Important: the parser is written for Ruby 1.9 or later. Check with

```sh
  ruby -v
  gem env
```

Nokogiri XML parser is required. To install it, the libxml2 libraries and
headers may need to be installed first, for example on Debian:

```sh
  apt-get install libxslt-dev libxml2-dev
  gem install bio-blastxmlparser
```

## Command line usage

### Usage

```
  blastxmlparser [options] file(s)

    -p, --parser name                Use split|nosplit parser (default split)
        --filter filter              Filtering expression
        --threads num                Use parallel threads
    -e, --exec filter                Evaluate filter (deprecated)

    -n, --named fields               Print named fields
        --output-fasta               Output FASTA
    -t, --template erb               Use ERB template for output

        --logger filename            Log to file (default stderr)
        --trace options              Set log level (default INFO, see bio-logger)
    -q, --quiet                      Run quietly
    -v, --verbose                    Run verbosely
        --debug                      Show debug messages
    -h, --help                       Show help and examples
```

### Examples

Print result fields of iterations containing 'lcl', using a regex

```sh
  blastxmlparser --filter 'iter.query_id=~/lcl/' test/data/nt_example_blastn.m7
```

prints a (default) tab delimited to stdout

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
  blastxmlparser --filter 'hsp["Hsp_bit-score"].to_i>145' test/data/nt_example_blastn.m7
```

Or the shorter 

```sh
  blastxmlparser --filter 'hsp.bit_score>145' test/data/nt_example_blastn.m7
```

And it is possible to print (non default) named fields where E-value < 0.001 
and hit length > 100. E.g.

```sh
  blastxmlparser -n 'hsp.evalue,hsp.qseq' --filter 'hsp.evalue<0.01 and hit.len>100' test/data/nt_example_blastn.m7

  1       5.82208e-34     AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCT...
  2       5.82208e-34     AGTGAAGCTTCTAGATATTTGGCGGGTACCTCTAATTTTGCCT...
  3       2.76378e-11     AATATGGTAGCTACAGAAACGGTAGTACACTCTTC     
  4       1.13373e-13     CTAAACACAGGAGCATATAGGTTGGCAGGCAGGCAAAAT 
  5       2.76378e-11     GAAGAGTGTACTACCGTTTCTGTAGCTACCATATT     
  etc. etc.
```

prints the evalue and qseq columns. To output FASTA use --output-fasta

```sh
  blastxmlparser --output-fasta --filter 'hsp.evalue<0.01 and hit.len>100' test/data/nt_example_blastn.m7
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

Another example outputs all definitions containing a string

```sh
  /blastxmlparser -n hit.hit_def --filter 'hit.hit_def=~/G. Ratti/i' 
```

## Modify output

To have more output options blastxmlparser can use an [ERB
template](http://www.stuartellis.eu/articles/erb/) for every match. This is a
very flexible option that can output textual formats such as JSON, YAML, HTML
and RDF. Examples are provided in
[./templates](https://github.com/pjotrp/blastxmlparser/templates/). A JSON
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

To get JSON, run it with

```sh
  blastxmlparser --template template/blast2json.erb --filter 'hsp.evalue<0.01 and hit.len>100' test/data/nt_example_blastn.m7
```

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

Likewise, using the RDF template

```sh
  blastxmlparser --template template/blast2rdf.erb --filter 'hsp.evalue<0.01 and hit.len>100' test/data/nt_example_blastn.m7
```

```ruby
:Minc_Contig50_77_42056___42484_1_64492  :query  :Minc_Contig50_77_42056___42484_1_64492_23
:Minc_Contig50_77_42056___42484_1_64492_23
  :query_id    "lcl|30_0",
  :query_def   "Minc_Contig50_77 [42056 - 42484] 1 64492",
  :num         23,
  :accession   "Minc02032",
  :id          "lcl|Minc02032",
  :len         147,
  :identity    60,
  :align_len   69,
  :bitscore    69.8753,
  :qseq        "ATGGGAGATGGAATTGAACCGTCATGGAAAGGGCCCAAACCGAAGCACAACCGACTGTGCCACCATCCA",
  :midline     "|||||||||||||||||||| |||||||| |       |||||||||||||||||||||||||||||||", 
  :hseq        "ATGGGAGATGGAATTGAACCATCATGGAATG-------ACCGAAGCACAACCGACTGTGCCACCATCCA",
  :evalue      8.1089e-12 .
```

### Metadata

Templates can also print data as a header of the JSON/YAML/RDF output. For this
use the '=' prefix with HEADER, BODY, FOOTER keywords in the template. A small example
can be

```Javascript
=HEADER
<% require 'json' %>
[
  { "HEADER": {
    "options":  <%= options.to_h.to_json %>,
    "files":    <%= ARGV %>,
    "version":  "<%= BLASTXML_VERSION %>"
  },
=BODY
  { "<%= hit.parent.query_def.strip %>": {
    "num":      <%= hit.hit_num %>,
    "id":       "<%= hit.hit_id %>",
    "len":      <%= hit.len %>,
    "E-value":  <%= hsp.evalue %>,
  },
=FOOTER
]
```

may generate something like

```Javascript
[
  { "HEADER": {
    "options":  {"template":"template/blast2json2.erb","filter":"hsp.evalue>0.01"},
    "files":    ["test/data/nt_example_blastn.m7"],
    "version":  "2.0.2-pre1"
  },
  { "I_1 [477 - 884]": {
    "num":       41,
    "id":        "lcl|X_42251",
    "len":       153,
    "E-value":   0.0247015,
  },
  { "I_1 [477 - 884]": {
    "num":       43,
    "id":        "lcl|V_105720",
    "len":       180,
    "E-value":   0.0247015,
  },
]
```

Note that the template is not smart enough to remove the final comma
from the last BODY element. To make it valid JSON that needs to be
removed. A future version may add a parameter to the BODY element or a
global rewrite function for this purpose. A simple

```ruby
<%= ( body.last? ? "" : "," ) %>
```

does not work here because the parallel parser does not
know which line is the last.

## Additional options

To use the high-mem version of the parser (slightly faster on single core) use

```sh
  blastxmlparser --parser nosplit --threads 1 -n 'hsp.evalue,hsp.qseq' --filter 'hsp.evalue<0.01 and hit.len>100' test/data/nt_example_blastn.m7
```

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

blastxmlparser is listed at http://biogems.info

## Copyright

Copyright (c) 2011-2015 Pjotr Prins under the MIT licence.  See LICENSE.txt and http://www.opensource.org/licenses/mit-license.html for further details.

