require 'gen/predicate'

# This class is just sugar on Gen::Predicate

module Gen
  class If < Predicate
    def self.[](*test_hashes)
      test_hash = {}
      test_hashes.each do |a_test_hash|
        test_hash.merge!(Hash.try_convert(a_test_hash) || {})
      end
      a_class = Class.new
      make_test a_class, :a_test, test_hash
      a_class.freeze
      a_class.new.method(:a_test).to_proc.freeze
    end
  end
end
