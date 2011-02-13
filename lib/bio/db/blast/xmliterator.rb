

module Bio
  module Blast

    # Iterate a BLAST file yielding (lazy) results
    class XmlIterator
      def initialize blastfilename
        @fn = blastfilename
      end
      
      def to_enum
        NokogiriBlastXml.new(File.new(@fn)).to_enum
      end
    end
  end
end
