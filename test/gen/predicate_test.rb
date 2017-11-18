require 'test_helper'
require 'gen/predicate'

class GenPredicateTest < Minitest::Test
  @@test_cases = [
    [true, {}, true],
    [[], {:length=> 0}, true],
    [false, {:to_s=>nil}, false],
    [Proc.new{true}, {:call=>true}, true],
    [Proc.new{false}, {:call=>true}, false],
    [Class, {:nesting=>[GenPredicateTest]}, false],
    [0, {:class=> Fixnum, :succ=> Proc.new{|x| x == 1}}, true],
    [Proc.new{}, {:arity=>0, :lambda? =>false, :parameters=>[]}, true],
    [Proc.new{}, {:arity=>0, :lambda? =>false, :parameters=>[:hi]}, false],
    [nil, {:to_a=>[], :to_i=>0, :to_r=>(0/1), :rationalize=>(0/1), :to_c=>(0+0i)}, true],
    [Proc.new{}, {:arity=>0, :call=>{:nil? =>true}, :lambda? =>false, :parameters=>[]}, true],
    [nil, {:to_a=>[], :to_i=>{:zero? => []}, :to_r=>(0/1), :rationalize=>(0/1), :to_c=>(0+0i)}, false],
    [nil, {:to_a=>[], :to_i=>{:zero? => true}, :to_r=>(0/1), :rationalize=>(0/1), :to_c=>(0+0i)}, true],
    [[], {:length=> 0, :to_a=> [], :to_s=> {:length=> {:succ=> 1, :to_s=> Proc.new{|x| x == '1'}}}}, false],
    [Proc.new{}, {:arity=>0, :lambda? =>false, :parameters=>{:empty? =>{:class=>{:name=>{:length=>9}}}}}, true],
    [Proc.new{}, {:arity=>0, :lambda? =>false, :parameters=>{:empty? =>{:class=>{:name=>{:length=>8}}}}}, false],
    [{:hi=>"there"}, {:any? =>true, :compare_by_identity? =>false, :inject=>[:hi, "there"], :all? =>true, :one? =>true, :none? =>false}, true],
    ['12', {:to_c=>(12+0i), :unicode_normalized? =>true, :encode=>"12", :next=>"13", :bytesize=>2, :chr=>"1", :length=>{:even? =>{:class=> TrueClass}}}, true],
    [[1,2,3], {:product=>[[1], [2], [3]], :first=>1, :reverse=>[3, 2, 1], :to_a=>{:last=>3, :join=>"12", :rotate=>[2, 3, 1]}, :uniq=>{:none? =>false, :minmax=>[1]}}, false],
    [[1,2,3], {:product=>[[1], [2], [3]], :first=>1, :reverse=>[3, 2, 1], :to_a=>{:last=>3, :join=>"123", :rotate=>[2, 3, 1]}, :uniq=>{:none? =>false, :minmax=>[1, 3]}}, true],
    [[1,2,3], {:product=>[[1], [2], [3]], :first=>1, :reverse=>[3, 2, 1], :to_a=>{:last=>3, :join=>"12", :rotate=>[2, 3, 1]}, :uniq=>{:none? =>false, :minmax=>[1, 3]}}, false],
    [{:hi=>"there"}, {:length=>1, :to_a=>[[:hi, "there"]], :flatten=>[:hi, "there"], :keys=>[:hi], :values=>["there"], :all? =>true, :one? =>true, :none? =>false, :zip=>[[[:hi, "there"]]]}, true],
  ]

  def setup
    @test_cases = @@test_cases
  end

  def test_all_given_cases
    @test_cases.each do |x, hash, result|
      klass = Class.new
      Gen::Predicate.make_test klass, :test_it, hash
      obj   = klass.new
      assert_equal result, obj.test_it(x), [x, hash, result]
    end
  end
end
