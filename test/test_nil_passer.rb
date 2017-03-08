require 'minitest/autorun'
require 'nil_passer'

class DummyList
  attr_accessor :x

  def initialize(x)
    @x = x
  end

  def map
    if block_given?
      yield @x
    end
  end
end

class NilPasserTest < Minitest::Test
  def Rails.path
    "/"
  end

  def setup
    @log = {}
    NilPasser.class_variable_set(:@@rails_logger, @log)
    def @log.tagged(arg, &block)
      unless arg == "no-nil"
        raise "bad arg"
      end
      self[arg] = block.call
    end
    def @log.info(str)
      unless str.present?
        raise "str not present"
      end
    end
  end

  def test_test_ignores_different_directory
    assert  @log.blank?
    NilPasser.test ["/some_non_existant_dir/"], Proc.new{|x| raise x.to_s}
    assert !@log.blank?
  end

  def test_test_ignores_good_block
    assert @log.blank?
    NilPasser.test [Rails.path], Proc.new{|x| x}
    assert @log.blank?
  end

  def test_test_catches_bad_block
    assert  @log.blank?
    NilPasser.test [Rails.path], Proc.new{|x| (raise "hi")}
    assert !@log.blank?
  end

  def test_test_catches_subtle_block
    assert  @log.blank?
    NilPasser.test [Rails.path], Proc.new{|x| x.nil? && (raise "hi")}
    assert !@log.blank?
  end

  def test_ignores_good_block_on_object
    obj = [1,2,3]
    assert @log.blank?
    NilPasser.new obj, :map
    obj.map{|x| x}
    assert @log.blank?
  end

  def test_catches_bad_block_on_object
    obj = [1,2,3]
    assert @log.blank?
    NilPasser.new obj, :map
    begin
      obj.map{|x| (raise "hi")}
      assert false
    rescue RuntimeError => e
      assert e.message == "hi"
    end
    assert @log.blank?
  end

  def test_catches_subtle_block_on_object
    obj = [1,2,3]
    assert @log.blank?
    NilPasser.new obj, :map
    obj.map{|x| x.nil? && (raise "hi")}
    assert @log.blank?
  end

  def test_ignores_good_block_on_class
    assert @log.blank?
    NilPasser.new DummyList
    obj = DummyList.new 3
    obj.map{|x| x}
    assert @log.blank?
  end

  def test_catches_bad_block
    assert @log.blank?
    NilPasser.new DummyList
    obj = DummyList.new 3
    begin
      obj.map{|x| (raise "hi")}
    rescue RuntimeError => e
      assert e.message == "hi"
    end
    assert @log.blank?
  end

  def test_catches_subtle_block
    assert @log.blank?
    NilPasser.new DummyList
    obj = DummyList.new 3
    obj.map{|x| x.nil? && (raise "hi")}
    assert @log.blank?
  end

  def test_to_old
    np = NilPasser.new nil, :to_s
    assert_equal np.to_old("hi"), :@@old_hi
    assert_equal np.to_old("[]"), :@@old_9193
  end
end

