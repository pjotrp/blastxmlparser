module Bio
  module Blast
    # Reads a full XML result and splits it out into a buffer for each
    # Iteration (query result).
    class XmlBulkParser
      def initialize fn
        @fn = fn
      end

      def each
        File.open(@fn) do | f |
          f.each_line do | line | 
            # p line
          end
        end
      end
    end
  end
end
