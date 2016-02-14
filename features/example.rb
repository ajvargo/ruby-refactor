module Outer
  module Inner
    class MyClass
      attr_reader :first, :last

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

      def has_great_than_three?
        puts "some are greater than 3" unless long_method.empty?
      end
    end
  end
end


describe "TestSubject" do

  context "the first context" do
    before(:each) do
      mock_advertiser_one = mock_model(Advertiser)
      mock_advertiser_one.stub(:uid).and_return("UID1")
    end
  end

end
