class RipController < ApplicationController
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :create, :update, :delete ],
         :redirect_to => { :action => :index }
            
  ID_METHODS = ['preview', 'show', 'query', 'edit', 'copy']
  
  def index
    @list = Rip.paginate :per_page => PER_PAGE, 
                         :page => params[:page],
                         :conditions => ['parent_id IS NULL AND current'] , 
                         :order => 'name'
    @rip = current 
  end
  
  def preview
    @rip ||= current
    render :action => :preview
  end
  
  def preview_temp
    @rip = Rip.new
    @rip.build_from params
    puts @rip.inspect
    @rip.ignore_name_validation = true
    if @rip.valid?
      render_rip
    else
      @attempted_action = 'previewed'
      render :partial => 'errors'
    end  
  end
  
  def show
    @rip ||= current
    if @rip.nil?
      return redirect_to :action => :index if params[:id] == controller_name
      raise ActiveRecord::RecordNotFound, "No rip named '#{params[:id]}' found"
    end
    
    fill_params
    @rip.all_required_set? ? render_rip : query
  end
    
  # query for params before show
  def query
    @rip ||= current
    render :action => :query, :layout => 'showrip'
  end
  
  def history
    @list = Rip.paginate :per_page => 1000, 
                         :page => params[:page],
                         :order => 'revision DESC', 
                         :conditions => ['parent_id IS NULL AND name = ?', 
                                         params[:id]]
    @rip = Rip.find params[:i].to_i if params[:i].to_i > 0
    @title = "History of #{params[:id]}"
    @use_id = true
    render :action => :index
  end
  
  def add
    @rip = Rip.build_type params['type']
  end
  
  def create
    @rip = Rip.new :revision => 1, :current => true
    @rip.build_from params
    @rip.ignore_name_validation = false
    if @rip.save
      flash[:notice] = "#{@rip.name} bitRip was added successfully"
      redirect_to :action => 'index', :id => @rip.name
    else
      render :action => 'add'
    end  
  end
  
  def copy
    @rip ||= current
    # preload dependent objects before resetting id
    @rip.children; @rip.navi_actions; @rip.bits
    @rip.id = nil
    @rip.name += '_copy'
    render :action => :add
  end
  
  def edit
    @rip ||= current
    @rip = @rip.to_type(params['type']) if params['type']
    # required if called by edit_id
    render :action => :edit
  end

  def update
    @rip = new_unless_sandbox
    @rip.build_from params
    if @rip.save_revision params[:id]     
      flash[:notice] = "#{@rip.name} bitRip was saved successfully"
      redirect_to :action => 'index', :id => @rip.name
    else
      @rip.id = params[:id]   # set id because @rip is new
      render :action => 'edit'
    end 
  end
  
  def cancel
    redirect_to :action => 'index', :id => params['rip']['name']
  end
  
  def sandbox
    params[:id] = Rip::SANDBOX_NAME
    @rip = current
    @rip = @rip.to_type(params['type']) if params['type']
  end
  
  def trash
    trash_query = "SELECT * FROM rips AS pri " +
                  "WHERE parent_id IS NULL AND NOT current AND revision = (" +
                  " SELECT MAX(revision) FROM rips " +
                  " WHERE name = pri.name)"
    @list = Rip.paginate_by_sql trash_query, 
                                :per_page => PER_PAGE, 
                                :page => params[:page]
    @rip = Rip.find_by_sql([trash_query + ' AND name = ?', params[:id]]).first if params[:id]
    @title = "Trash"
    @use_id = true
    render :action => :index
  end
  
  def delete
    rip = Rip.find params[:id]
    rip.current = false
    if rip.save
      flash[:notice] = "Rip was moved to trash"
    else
      flash[:notice] = "Rip could not be deleted: #{rip.errors.full_messages.join(", ")}"
    end  
    redirect_to :action => :index
  end
  
  def edit_js
    respond_to do |format|
      format.js {render :action => :edit_js, :layout => false}
    end    
  end

  def method_missing(symbol, *args)
    if method = id_method?(symbol)
      @rip = Rip.find params[:id]
      @use_id = true
      self.send method
    else
      super(symbol, args)
    end
  end
  
  def respond_to?(symbol, include_private = false)
    super(symbol, include_private) || id_method(symbol)
  end


private

  def current
    Rip.find :first, :conditions => ['name = ? AND current', params[:id]]
  end

  def render_rip
    @message = Scrubator.new(@rip).ripit 
    if @message.nil?
      render :action => :show, :layout => 'showrip'
    else 
      @attempted_action = 'viewed'
      render :partial => 'errors'
    end
  end
  
  def fill_params
    @rip.navi_actions.each do |navi|
      navi.form_fields.each do |field|
        field.value = params[field.name] if params[field.name]
      end
    end
  end
  
  def id_method?(symbol)
    (symbol =~ /^(.*)_id$/ && ID_METHODS.include?($1)) ? $1 : nil
  end

  def new_unless_sandbox
    prev = Rip.find(params[:id])
    (prev && prev.name == 'sandbox') ? prev : Rip.new
  end
end
