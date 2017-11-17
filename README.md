# Nil-Passer [![Build Status](https://travis-ci.org/michaeljklein/nil-passer.svg?branch=master)](https://travis-ci.org/michaeljklein/nil-passer)

Ever been sick of blocks not handling nil in Ruby, or more specifically Rails?

This gem defines the [`NilPasser`](https://github.com/michaeljklein/nil-passer/blob/master/lib/nil_passer.rb#L3) class, which can be used to monitor all passing of blocks on an object, through a specific method, or to a class.

Each block passed is passed `nil` and the execution _usually_ continues normally. (Usually meaning you probably don't want to use this in production.)

During or after execution, you can `grep -F '^[no_nil]'` on your logs to get all the results.

Loosely inspired by the [`bullet`](https://github.com/flyerhzm/bullet) gem.

# Examples

From [the tests](https://github.com/michaeljklein/nil-passer/blob/master/test/test_nil_passer.rb), we have example usage for "good, bad, and subtle" blocks:


## Good

This is the control: we provide the caller's location and the identity (function) block ([source](https://github.com/michaeljklein/nil-passer/blob/master/test/test_nil_passer.rb#L45)):

```
  def test_test_ignores_good_block
    assert @log.blank?
    NilPasser.test [Rails.path], Proc.new{|x| x}
    assert @log.blank?
  end
```


## Bad

This is a simple exception-handling case, where the block accepts `nil` but always raises an exception ([source](https://github.com/michaeljklein/nil-passer/blob/master/test/test_nil_passer.rb#L51)):

```
  def test_test_catches_bad_block
    assert  @log.blank?
    NilPasser.test [Rails.path], Proc.new{|x| (raise "hi")}
    assert !@log.blank?
  end
```


## Subtle

This is an example of a block that _only_ raises an exception when passed `nil` ([source](https://github.com/michaeljklein/nil-passer/blob/master/test/test_nil_passer.rb#L57)):

```
  def test_test_catches_subtle_block
    assert  @log.blank?
    NilPasser.test [Rails.path], Proc.new{|x| x.nil? && (raise "hi")}
    assert !@log.blank?
  end
```



