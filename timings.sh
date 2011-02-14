#! /bin/sh

echo Parsing test/data/nt_example_blastn.m7
ls -l test/data/nt_example_blastn.m7

# first fill cache
echo ====
echo Null
cat test/data/nt_example_blastn.m7 > /dev/null
time cat test/data/nt_example_blastn.m7 > /dev/null
echo ====
echo Nokogiri SAX
time ./sample/nokogiri_sax.rb > /dev/null
echo ====
echo LibXML SAX
time ./sample/libxml_sax.rb > /dev/null
echo ====
echo Nokogiri DOM
time sample/nokogiri_dom.rb > /dev/null
echo ====
echo Nokogiri split DOM
time sample/nokogiri_split_dom.rb > /dev/null
echo ====
echo BioRuby ReXML DOM parser
time sample/bioruby.rb > /dev/null
 
 
 
