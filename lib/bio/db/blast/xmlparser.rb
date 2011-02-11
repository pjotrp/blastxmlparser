# require 'nokogiri'

module Bio
  module Blast
    # Reads a full XML result and splits it out into a buffer for each
    # Iteration (query result).
    class XmlBulkParser
      # include Nokogiri
      def initialize fn
        @fn = fn
      end

      def each
        f = File.open(@fn)
        f.each_line do | line |
          break if line.strip == "<Iteration>"
        end
        each_iteration(f) do | b |
          # input = Nokogiri::XML(b.join)
          yield b
        end
      end

    private

      def each_iteration f
        b = ["<Iteration>"]
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
