class RipController < ApplicationController
  
  def index
    @list = Rip.find :all, :order => 'name'
  end
  
  def preview
    @rip = Rip.find params[:id]
  end
  
  def show
    @rip = Rip.find_by_name params[:id]
    if @rip.nil?
      raise ActiveRecord::RecordNotFound, "No rip named '#{params[:id]}' found"
    end
    
    @output = Scrubator.new.ripit @rip, params
    render :action => 'show', :layout => 'showrip'
  end
  
  def edit
    @rip = Rip.find params[:id]
  end

  def update
    @rip = Rip.find params[:id]
    @rip.attributes = params[:rip]
    @rip.bits.clear
    params[:bit_order].split(',').each do |index| 
      @rip.bits.build(params[:bits][index]) 
    end
    # TODO: should validate all first?
    if @rip.save
      flash[:notice] = "#{@rip.name} bitRip was saved successfully"
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end  
  end
  
  def add
    @rip = Rip.new
  end
  
  def create
    @rip = Rip.new params[:rip]
    params[:bits].each_value { |bit| @rip.bits.build(bit) }
    if @rip.save
      flash[:notice] = "#{@rip.name} bitRip was added successfully"
      redirect_to :action => 'index'
    else
      render :action => 'add'
    end  
  end
  
  
private

end
