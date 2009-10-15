# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  helper :all # include all helpers, all the time
  helper_method :msg

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :pwd
  
  before_filter :init_vars
  after_filter :set_charset

  def msg(key)
    Message.get(key)
  end

  def init_vars
    @bottom_js = ""
  end

  def set_charset
    content_type = headers["Content-Type"] || 'text/html'
    if /^text\//.match(content_type)
      headers["Content-Type"] = "#{content_type}; charset=utf-8" 
    end
  end
  
  def rescue_action_in_public(exception)
    case exception
      when ::ActionController::RoutingError, ActiveRecord::RecordNotFound, ::ActionController::UnknownAction, ::ActionController::InvalidAuthenticityToken
        render(:file => "#{RAILS_ROOT}/public/404.html",
               :status => "404 Not Found")
      else
        render(:file => "#{RAILS_ROOT}/public/500.html",
               :status => "500 Error")
        SystemNotifier.deliver_exception_notification(self, request, exception)
    end                    
  end
end
