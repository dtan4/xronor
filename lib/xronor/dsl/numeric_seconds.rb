# This file is derived from Whenever, Copyright (c) 2017 Javan Makhmali
# Original code:
# https://github.com/javan/whenever/blob/1dcb91484e6f1ee91c9272daccbe84111754102b/lib/whenever/numeric_seconds.rb
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# Modifications are Copyright 2017 Daisuke Fujita. License under the MIT License.

module Xronor
  class DSL
    class NumericSeconds
      def self.seconds(number, units)
        self.new(number).send(units)
      end

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
