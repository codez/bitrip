class RipController < ApplicationController
  
  def index
    @list = Rip.find :all, :order => 'name'
  end
  
  def show
    rip = Rip.find params[:id]
    @output = Scrubator.new.ripit rip, params
  end
  
  def edit
    @rip = Rip.find params[:id]
  end
  
end
