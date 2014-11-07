require 'erb'

module Bio

  class Template

    def initialize fn
      raise "Can not find template #{fn}!" if not File.exist?(fn)
      @erb = ERB.new(File.read(fn))
    end

    def result text
      @erb.result(text)
    end
  end
end
