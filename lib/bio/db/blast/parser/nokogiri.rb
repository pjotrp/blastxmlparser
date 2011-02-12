
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
    module MapXPath
      include XPath
      def MapXPath.define_s map
        map.each { |k,v| 
          define_method(v) {
            field(k)
          }
        }
      end
      def MapXPath.define_i map
        map.each { |k,v| 
          define_method(v) {
            field(k).to_i
          }
        }
      end
    end

    class NokogiriBlastHit
      include MapXPath
      MapXPath.define_s 'Hit_id' => :id,
                        'Hit_def' => :def,
                        'Hit_accession' => :accession
      MapXPath.define_i 'Hit_num' => :num, 
                        'Hit_len' => :len

      def initialize xml
        @xml = xml
      end
      
    end

    class NokogiriBlastIterator
      include MapXPath

      MapXPath.define_s 'Iteration_query-ID'  => :query_id,  
                        'Iteration_query-def' => :query_def 

      MapXPath.define_i 'Iteration_iter-num'  => :iter_num,
                        'Iteration_query-len' => :query_len


      def initialize xml
        @xml = xml
      end

      def hits
        Enumerator.new { |yielder|
          @xml.xpath("//Hit").each { | hit |
            yielder.yield NokogiriBlastHit.new(hit)
          }
        }
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
