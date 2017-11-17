# Nil Passer [![Build Status](https://travis-ci.org/michaeljklein/nil-passer.svg?branch=master)](https://travis-ci.org/michaeljklein/nil-passer)

Ever been sick of blocks not handling nil in Ruby, or more specifically Rails?

This gem defines the [`NilPasser`](https://github.com/michaeljklein/nil-passer/blob/master/lib/nil_passer.rb#L3) class, which can be used to monitor all passing of blocks on an object, through a specific method, or to a class.

Each block passed is passed `nil` and the execution _usually_ continues normally. (Usually meaning you probably don't want to use this in production.)

During or after execution, you can `grep -F '^[no_nil]'` on your logs to get all the results.

Loosely inspired by the [`bullet`](https://github.com/flyerhzm/bullet) gem.
