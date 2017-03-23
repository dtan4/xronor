module Xronor
  module Generator
    class ERB
      class << self
        def generate_all_in_one(filename, options)
          @jobs = Xronor::Parser.parse(filename)
          erb = open(options[:template]).read
          ::ERB.new(erb, nil, "-").result(binding)
        end
      end
    end
  end
end
