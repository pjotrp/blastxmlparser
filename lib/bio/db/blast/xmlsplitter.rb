require 'enumerator' 

module Bio
  module BlastXMLParser
    # Reads a full XML result and splits it out into a buffer for each
    # Iteration (query result).
    class XmlSplitterIterator
      # include Enumerable

      def initialize fn
        @fn = fn
      end

      def to_enum 
        Enumerator.new do | yielder | 
          logger = Bio::Log::LoggerPlus['bio-blastxmlparser']
          logger.info("split file parsing #{@fn}")
          f = File.open(@fn)
          # Skip BLAST header
          f.each_line do | line |
            break if line.strip == "<Iteration>"
          end
          # Return each Iteration as an XML DOM
          each_iteration(f) do | buf |
            iteration = Nokogiri::XML.parse(buf.join) { | cfg | cfg.noblanks }
            yielder.yield NokogiriBlastIterator.new(iteration,self,:prefix=>nil)
          end
        end
      end

    private

      def each_iteration f
        # b = ["<?xml version=\"1.0\"?>\n","<Iteration>\n"]
        # b = []
        b = ["<Iteration>\n"]
        f.each_line do | line |
          b << line
          if line.strip == "</Iteration>"
            yield b
            b = []
          end
        end
      end
    end
  end
end
