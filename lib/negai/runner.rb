=begin

This file is part of the negai project, http://github.com/tario/negai

Copyright (c) 2009-2010 Roberto Dario Seminara <robertodarioseminara@gmail.com>

negai is free software: you can redistribute it and/or modify
it under the terms of the gnu general public license as published by
the free software foundation, either version 3 of the license, or
(at your option) any later version.

negai is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.  see the
gnu general public license for more details.

you should have received a copy of the gnu general public license
along with negai.  if not, see <http://www.gnu.org/licenses/>.

=end
require "shikashi"

module Negai
class Runner

  #
  #Set the proc to intercept the standard output of the scripts
  #Example:
  #
  #  runner = Negai::Runner.new
  #
  #  runner.output_proc = proc do |*data|
  #   print "stdout: #{data.join}\n"
  #  end
  #
  #  priv = Negai.empty_privileges
  #  priv.allow_method :print
  #
  #  runner.run('print "hello world\n"', :privileges => priv)
  #
  attr_accessor :output_proc

  class PrintWrapper < Shikashi::Sandbox::MethodWrapper
    attr_accessor :output_proc
    def call(*args)
      output_proc.call(*args)
      original_call(*args)
    end
  end

  class PseudoWrapperClass
    attr_accessor :output_proc
    def redirect_handler(klass, recv, method_id, method_name, sandbox)
      mw = PrintWrapper.redirect_handler(klass, recv, method_id, method_name, sandbox) do |x|
        x.output_proc = output_proc
      end

      mw
    end
  end

   #Run the code in sandbox with the given privileges, also run privileged code in the sandbox context for
    #execution of classes and methods defined in the sandbox from outside the sandbox if a block is passed
    # (see examples)
    #
    #call-seq: run(arguments)
    #
    #Arguments
    #
    # :code       Mandatory argument of class String with the code to execute restricted in the sandbox
    # :privileges Optional argument of class Shikashi::Sandbox::Privileges to indicate the restrictions of the
    #             code executed in the sandbox. The default is an empty Privileges (absolutly no permission)
    #             Must be of class Privileges or passed as hash_key (:privileges => privileges)
    # :binding    Optional argument with the binding object of the context where the code is to be executed
    #             The default is a binding in the global context
    # :source     Optional argument to indicate the "source name", (visible in the backtraces). Only can
    #             be specified as hash parameter
    #
    #
    #The arguments can be passed in any order and using hash notation or not, examples:
    #
    # runner.run code, privileges
    # runner.run code, :privileges => privileges
    # runner.run :code => code, :privileges => privileges
    # runner.run code, privileges, binding
    # runner.run binding, code, privileges
    # #etc
    # runner.run binding, code, privileges, :source => source
    # runner.run binding, :code => code, :privileges => privileges, :source => source
    #
    #Example:
    #
    # require "rubygems"
    # require "negai"
    #
    # privileges = Negai.empty_privileges
    # privileges.allow_method :print
    #
    # runner = Negai::Runner.new
    # runner.run('print "hello world\n"', :privileges => privileges )
    #

  def run(*args)
    s = Shikashi::Sandbox.new

    if output_proc then
      pseudo_class = PseudoWrapperClass.new
      pseudo_class.output_proc = output_proc

      s.redirect :print, :wrapper_class => pseudo_class
    end

    s.run(*args)
  end
end
end
