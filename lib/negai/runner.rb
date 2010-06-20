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

  def sandbox
    Shikashi::Sandbox.new
  end

  def run(*args)
    s = sandbox

    pseudo_class = PseudoWrapperClass.new
    pseudo_class.output_proc = output_proc

    s.redirect :print, :wrapper_class => pseudo_class
    s.run(*args)
  end
end
end
