
require 'nokogiri'
require 'enumerator'

module Bio
  module Blast

    module XPath
      def field name
        @xml.xpath(name+"/text()").to_s
      end

      def define_xml_s map
        map.each { |k,v| 
          define_method(k) {
            field(v)
          }
        }
      end
    end

    class NokogiriBlastHit
    end


    class NokogiriBlastIterator
      include XPath

      define_xml_s { :query_id  => 'Iteration_query-ID',
                     :query_def => 'Iteration_query-def' }

      INTS = { :iter_num => 'Iteration_iter-num',
               :query_len => 'Iteration_query-len' }

      INTS.each { |k,v| 
        define_method(k) {
          field(v).to_i
        }
      }

      def initialize xml
        @xml = xml
      end

      def hits

      end

    end

    class NokogiriBlastXml 
      def initialize xml
        @xml = xml
      end

      def to_enum
        Enumerator.new { |yielder| 
          each { | iterator | yielder.yield(iterator) }
        }
      end

      def each &block
        input = Nokogiri::XML(@xml)
        input.root.xpath("//Iteration").each do | iteration |
          block.call(NokogiriBlastIterator.new(iteration))
        end
      end
    end
  end
end
