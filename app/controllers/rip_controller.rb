class RipController < ApplicationController
  layout 'showrip', :only => :show
  
  def index
    @list = Rip.find :all, :order => 'name'
  end
  
  def show
    @rip = Rip.find_by_name params[:id]
    if @rip.nil?
      raise ActiveRecord::RecordNotFound, "No rip named '#{params[:id]}' found"
    end
    
    @output = Scrubator.new.ripit @rip, params
  end
  
  def edit
    @rip = Rip.find params[:id]
  end

  def update
    @rip = Rip.find params[:id]
  end
  
  def add
    @rip = Rip.find params[:id]
  end
  
  def create
    @rip = Rip.find params[:id]
  end
private
 
  
end
