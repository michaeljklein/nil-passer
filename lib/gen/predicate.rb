require 'gen/code'

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
          make_test_code(value)
        elsif value.is_a? Proc
          "return false unless #{bind_proc  value}.call(#{local_var})"
        else
          "return false unless #{bind_const value} ==   #{local_var} "
        end]
      end.flatten << "return true"
    end

    # given a class, a name for the test (instance) method, and a test hash, generate a predicate
    def make_test(klass, test_name, test_hash)
      test_code = self.make_test_code test_hash
      test_code = self.proc_block test_code, 'x_0'

      arg_vars  = []
      args      = []
      @bound_procs.zip(0..Float::INFINITY).each do |bound_proc, num|
        arg_vars << "proc_#{num}"
        args     << bound_proc
      end
      @bound_constants.zip(0..Float::INFINITY).each do |bound_const, num|
        arg_vars << "const_#{num}"
        args     << bound_const
      end

      test_code = self.proc_block test_code, arg_vars.to_s.gsub(/[\[\]\"]/, '').freeze
      klass.class_exec do
        define_method test_name, eval(test_code).call(*args)
      end
    end

    # An alias of `#make_test`
    def self.make_test(klass, test_name, test_hash)
      self.new.make_test klass, test_name, test_hash
    end
  end
end

