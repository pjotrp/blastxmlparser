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
time ./sample/nokogiri_sax.rb 
echo ====
echo LibXML SAX
time ./sample/libxml_sax.rb 
echo ====
echo Nokogiri DOM
time sample/nokogiri_dom.rb > /dev/null
 
