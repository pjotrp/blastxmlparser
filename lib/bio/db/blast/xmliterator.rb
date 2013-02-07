

module Bio
  module BlastXMLParser

    # Iterate a BLAST file yielding (lazy) results
    class XmlIterator
      def initialize blastfilename
        @fn = blastfilename
      end
      
      def to_enum
        logger = Bio::Log::LoggerPlus['bio-blastxmlparser']
        logger.info("parsing (full) #{@fn}")
        NokogiriBlastXml.new(File.new(@fn)).to_enum
      end
    end
  end
end
