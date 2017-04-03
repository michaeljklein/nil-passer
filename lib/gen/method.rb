
module Gen
  class Gen::Method
    # define a method on both the class and the instance
    def self.def_self(method_name, &block)
      define_method           method_name, block # defines instance method
      define_singleton_method method_name, block # defines class method
    end

    # define a block generator on both the class and the instance
    def self.def_block_gen(name, initializer=name.to_s, default_args=nil)
      def_self "#{name}_block".to_sym do |code_lines=nil, args=default_args, &block|
        code_lines ||= block.call
        ["#{initializer} do #{args && "|#{args}|"}",
         indent(code_lines),
         "end"].join("\n")
      end
    end

    # Wrap a code block to keep variables local
    #   puts (Benchmark.measure do
    #       1000000.times do
    #         CodeGen.wrap_it{}
    #       end
    #   end)
    #     0.780000   0.020000   0.800000 (  0.805655)
    def_self :wrap_it do |&block|
      block&.call
    end.freeze

    # indent some lines of code (with two spaces). Accepts a newline seperated string or an array of strings.
    def_self :indent do |code_lines|
      if code_lines.is_a? String
        code_lines.lines.map{|line| "  " + line}.join
      elsif code_lines.is_a?(Array)
        code_lines.map{|line| indent line}
      end
    end
  end
end

