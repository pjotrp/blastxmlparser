
require 'nokogiri'
require 'enumerator'

module Bio
  module Blast

    module XPath
      def field name
        if @prefix
          @xml.xpath(@prefix+name+'/text()').to_s
        else
          @xml.xpath(name+'/text()').to_s
        end
      end

    end

    # Some magic to create XML -> method mappers, on the fly
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
      def MapXPath.define_f map
        map.each { |k,v| 
          define_method(v) {
            field(k).to_f
          }
        }
      end
      def [] name
        field(name)
      end

    end

    class NokogiriBlastHsp
      include MapXPath
      attr_reader :parent
      MapXPath.define_s 'Hsp_id'          => :hsp_id,
                        'Hsp_qseq'        => :qseq,
                        'Hsp_hseq'        => :hseq,
                        'Hsp_midline'     => :midline
      MapXPath.define_i 'Hsp_num'         => :hsp_num,
                        'Hsp_score'       => :score,
                        'Hsp_query-from'  => :query_from,
                        'Hsp_query-to'    => :query_to,
                        'Hsp_hit-from'    => :hit_from,
                        'Hsp_hit-to'      => :hit_to,
                        'Hsp_query-frame' => :query_frame,
                        'Hsp_hit-frame'   => :hit_frame,
                        'Hsp_identity'    => :identity,
                        'Hsp_positive'    => :positive,
                        'Hsp_align-len'   => :align_len
      MapXPath.define_f 'Hsp_bit-score'   => :bit_score,
                        'Hsp_evalue'      => :evalue
                         
      def initialize xml, parent
        @xml = xml
        @parent = parent
      end

      def to_s
        s = <<EOM
  hit_num=#{parent.hit_num}, hsp_num=#{hsp_num}, score=#{score}, bit_score=#{bit_score}
EOM
      end
      
    end

    class NokogiriBlastHit
      include MapXPath
      attr_reader :parent
      MapXPath.define_s 'Hit_id' => :hit_id,
                        'Hit_def' => :hit_def,
                        'Hit_accession' => :accession
      MapXPath.define_i 'Hit_num' => :hit_num, 
                        'Hit_len' => :len

      def initialize hit, parent
        @xml = hit
        @parent = parent
      end

      def hsps
        Enumerator.new { |yielder|
          @xml.children.each do | hit_field |
            if hit_field.name == 'Hit_hsps'
              hit_field.children.each do | hsp |
                if hsp.name == 'Hsp'
                  yielder.yield NokogiriBlastHsp.new(hsp,self)
                end
              end
            end
          end
        }
      end

      def to_s
        s = <<EOM
iter_num=#{parent.iter_num}, hit_id=#{hit_id}, hit_def=#{hit_def}, hit_num=#{hit_num}
EOM
      end
      
    end

    class NokogiriBlastIterator
      include MapXPath
      attr_reader :parent
      MapXPath.define_s 'Iteration_query-ID'  => :query_id,  
                        'Iteration_query-def' => :query_def 

      MapXPath.define_i 'Iteration_iter-num'  => :iter_num,
                        'Iteration_query-len' => :query_len


      def initialize iterator, parent, opts = { :prefix => nil }
        @parent = parent
        @prefix = opts[:prefix]
        @xml = if iterator.name == 'document'
                 iterator.children.first
               else
                 iterator
               end
        name2 = @xml.name
        raise "Error in BLAST XML, expected Iteration node, but got #{name2}" if name2 != 'Iteration'
        # p [:iter,@prefix,'@@Iteratition_iter-num',field('Iteration_iter-num')]
        # print @xml.to_s
      end

      def hits
        Enumerator.new { |yielder|
          @xml.children.each do | iter_field |
            if iter_field.name == 'Iteration_hits'
              iter_field.children.each do | hit |
                if hit.name == 'Hit'
                  yielder.yield NokogiriBlastHit.new(hit,self)
                end
              end
            end
          end
        }
      end

      def to_s
        s = <<EOM
iter_num=#{iter_num}, query_id=#{query_id}
EOM
      end
    end

    class NokogiriBlastXml 
      def initialize document
        @xml = document
      end

      def to_enum
        Enumerator.new { |yielder| 
          each { | iterator | yielder.yield(iterator) }
        }
      end

      def each &block
        doc = Nokogiri::XML(@xml) { | cfg | cfg.noblanks }
        doc.root.children.each do |blastnode|
          if blastnode.name == 'BlastOutput_iterations'
            blastnode.children.each do | iteration |
              if iteration.name == 'Iteration'
                block.call(NokogiriBlastIterator.new(iteration,self))
              end
            end
          end
        end
      end
    end
  end
end
