class BitController < ApplicationController
  
  def add
    @bit = Bit.new
    @bit.generalize = false
  end
  
  def remove
  end
  
end
