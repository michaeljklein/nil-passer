require 'gen/code'
require 'utils/self'

module Gen
  class Gen::Predicate < Gen::Code
    # you enter a nested hash where the branches define the execution path and the leaves either have a value 
    # (which will be compared with the actual value) or a single-argument Proc, which is called on it
    # e.g.
    #   pry(main)> make_test({:to_a=> {:length=>5}}).call (1..4)
    #   => false
    #   pry(main)> make_test({:to_a=> {:length=>5}}).call (1..5)
    #   => true
    def make_test_code(test_hash)
      input_var = local_var
      test_hash.map do |method, value|
        [self.new_local_var("#{input_var}.#{method}"),
        if value.is_a? Hash
          make_eval_test(value)
        elsif value.is_a? Proc
          "return false unless #{bind_proc  value}.call(#{local_var})"
        else
          "return false unless #{bind_const value} ==   #{local_var} "
        end]
      end.flatten << "return true"
    end

    # Outputs a `Proc` generated from the given `Hash`
    def make_test(test_hash)
      test_code = self.make_test_code test_hash
      test_code = self.proc_block test_code, 'x_0'
      self.to_proc test_code
    end
  end
end

