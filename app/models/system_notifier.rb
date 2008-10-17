require 'pathname'

class SystemNotifier < ActionMailer::Base
  
  def exception_notification(controller, request, exception)
    @subject = sprintf("[ERROR] %s\#%s (%s)",
                       controller.controller_name,
                       controller.action_name,
                       exception.class)
    @body = { "controller" => controller,
              "request"    => request,
              "exception"  => exception,
              "backtrace"  => sanitize_backtrace(exception.backtrace),
              "host"       => request.env["HTTP_HOST"],
              "rails_root" => rails_root }
    @sent_on    = Time.now
    @from       = 'webmaster@codez.ch'
    @recipients = 'webmaster@codez.ch'
    @headers    = {}            
  end
  
private

  def sanitize_backtrace(trace)
    re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
    trace.map do |line|
      Pathname.new(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s
    end
  end  
  
  def rails_root
    @rails_root ||= Pathname.new(RAILS_ROOT).cleanpath.to_s
  end
  
end  