# find local plugin installation, and use it when there
rootpath = File.dirname(File.dirname(__FILE__))
bio_logger_path = File.join(rootpath,'..','bioruby-logger','lib')
if File.directory? bio_logger_path
  $: << bio_logger_path
  $stderr.print "bio-logger loaded directly\n"
else
  require "rubygems"
  gem "bio-logger"
end
require 'bio-logger'

Bio::Log::LoggerPlus.new('bio-blastxmlparser')

require 'bio/db/blast/xmlsplitter'
require 'bio/db/blast/xmliterator'
require 'bio/db/blast/parser/nokogiri'
