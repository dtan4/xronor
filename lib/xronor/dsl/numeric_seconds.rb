# Inspired by https://github.com/javan/whenever/blob/1dcb91484e6f1ee91c9272daccbe84111754102b/lib/whenever/numeric_seconds.rb

module Xronor
  class DSL
    class NumericSeconds
      def initialize(number)
        @number = number.to_i
      end

      def seconds
        @number
      end
      alias :second :seconds

      def minutes
        @number * 60
      end
      alias :minute :minutes

      def hours
        @number * 60 * 60
      end
      alias :hour :hours

      def days
        @number * 60 * 60 * 24
      end
      alias :day :days

      def weeks
        @number * 60 * 60 * 24 * 7
      end
      alias :week :weeks

      def months
        @number * 60 * 60 * 24 * 30
      end
      alias :month :months

      def years
        @number * 60 * 60 * 24 * 365 + 60 * 60 * 6 # consider leap year
      end
      alias :year :years
    end
  end
end
