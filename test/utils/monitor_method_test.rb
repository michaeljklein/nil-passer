require 'test_helper'
require 'utils/monitor_method.rb'

class WrapMethodTest < Minitest::Test
  def test_no_new
    assert_raises NoMethodError do
      MonitorMethod.new
    end
  end

  def test_frozen
    assert MonitorMethod.frozen?
  end

  def test_method_monitor_skipping_1
    options = [ nil, proc{nil}, proc{false}, proc{true} ]
    options.product(options).select do |x, y|
      x&.call == false || y&.call == false
    end.each do |x,y|
      assert (MonitorMethod.method_monitor x, y do |*_, &_|
        raise "the monitor ran: #{[x&.call, y&.call]}"
      end.call(nil).call)
    end

    assert_raises RuntimeError do
      MonitorMethod.method_monitor do |*_, &_|
        raise "the monitor ran"
      end.call(nil).call
    end
  end

  def test_method_monitor_passes_args_and_block_2
    some_procs = (1..5).to_a.map{ proc{} }
    new_args, new_block = MonitorMethod.method_monitor do |*args, &block|
      [args, block]
    end.call(nil).call(*some_procs, &some_procs.first)
    assert_equal some_procs,       new_args
    assert_equal some_procs.first, new_block
  end

  def test_method_monitor_passes_args_and_block_on_nil_3
    some_procs = (1..5).to_a.map{ proc{} }
    new_args, new_block = MonitorMethod.method_monitor do |*args, &block|
      nil
    end.call(nil).call(*some_procs, &some_procs.first)
    assert_equal some_procs,       new_args
    assert_equal some_procs.first, new_block
  end

  def test_method_monitor_passes_args_and_block_on_false_4
    some_procs = (1..5).to_a.map{ proc{} }
    new_args, new_block = MonitorMethod.method_monitor do |*args, &block|
      false
    end.call(nil).call(*some_procs, &some_procs.first)
    assert_equal some_procs,       new_args
    assert_equal some_procs.first, new_block
  end

  def test_unbound_method_monitor_skipping_5
    options = [ nil, proc{nil}, proc{false}, proc{true} ]
    options.product(options).product(options).map{|x| x.flatten}.select do |x, y, z|
      x&.call == false || y&.call == false || z&.call == false
    end.each do |x, y, z|
      assert (MonitorMethod.unbound_method_monitor x, y, z do |_, *_, &_|
        raise "the monitor ran: #{[x&.call, y&.call, z&.call]}"
      end.call(nil).call(nil).call)
    end

    assert_raises RuntimeError do
      MonitorMethod.unbound_method_monitor do |_, *_, &_|
        raise "the monitor ran"
      end.call(nil).call(nil).call
    end
  end

  def test_unbound_method_monitor_passes_args_and_block_6
    some_procs = (1..5).to_a.map{ proc{} }
    new_args, new_block = MonitorMethod.unbound_method_monitor do |_, *args, &block|
      [args, block]
    end.call(nil).call(nil).call(*some_procs, &some_procs.first)
    assert_equal some_procs,       new_args
    assert_equal some_procs.first, new_block
  end

  def test_unbound_method_monitor_passes_args_and_block_on_nil_7
    some_procs = (1..5).to_a.map{ proc{} }
    new_args, new_block = MonitorMethod.unbound_method_monitor do |_, *args, &block|
      nil
    end.call(nil).call(nil).call(*some_procs, &some_procs.first)
    assert_equal some_procs,       new_args
    assert_equal some_procs.first, new_block
  end

  def test_method_monitor_passes_args_and_block_on_false_8
    some_procs = (1..5).to_a.map{ proc{} }
    new_args, new_block = MonitorMethod.unbound_method_monitor do |_, *args, &block|
      false
    end.call(nil).call(nil).call(*some_procs, &some_procs.first)
    assert_equal some_procs,       new_args
    assert_equal some_procs.first, new_block
  end
end

