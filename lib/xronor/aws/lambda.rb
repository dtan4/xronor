module Xronor
  module AWS
    class Lambda
      def initialize(client: Aws::Lambda::Client.new)
        @client = client
      end

      def retrieve_function_arn(name)
        function = @client.list_functions.functions.find { |fn| fn.function_name == name }
        function ? function.function_arn : ""
      end
    end
  end
end
