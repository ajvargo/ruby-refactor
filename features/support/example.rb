module Outer
  module Inner
    class MyClass
      attr_reader :first, last

      def initialize(something)
        @something = something
      end

      def long_method
        [1, 2, 3, 4, 5].each do |value|
          puts value
        end
        
        greater_than_three = [1, 2, 3, 4, 5].find_all do |value|
          value > 3
        end
        
        greater_than_three.each do |value|
          puts "#{value} is greater than three"
        end
      end
    end
  end
end
