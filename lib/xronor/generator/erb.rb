module Xronor
  module Generator
    class ERB
      class << self
        def generate(filename, options)
          @jobs = Xronor::Parser.parse(filename)
          erb = open(options[:template]).read
          ::ERB.new(erb, nil, "-").result(binding)
        end
      end
    end
  end
end
