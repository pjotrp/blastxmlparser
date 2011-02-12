
require 'nokogiri'
require 'enumerator'

module Bio
  module Blast

    module XPath
      def field name
        @xml.xpath(name+"/text()").to_s
      end

    end

    # Some magic to creat XML -> method mappers, on the fly
    module MapXML
      include XPath
      def MapXML.define_s map
        map.each { |k,v| 
          define_method(v) {
            field(k)
          }
        }
      end
      def MapXML.define_i map
        map.each { |k,v| 
          define_method(v) {
            field(k).to_i
          }
        }
      end
    end

    class NokogiriBlastHit
    end

    class NokogiriBlastIterator
      include MapXML

      MapXML.define_s 'Iteration_query-ID'  => :query_id,  
                      'Iteration_query-def' => :query_def 

      MapXML.define_i 'Iteration_iter-num'  => :iter_num,
                      'Iteration_query-len' => :query_len


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
