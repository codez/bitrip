require "digest"
require "digest/sha1"

class Message < CachedModel
  
  CONTEXT_HELP = 'help'
  CONTEXT_FAQ = 'faq'
  CONTEXTS = [CONTEXT_HELP, CONTEXT_FAQ]
  
  SALT = 'ch1ch1b00'
  
  validates_uniqueness_of :key
  validates_presence_of :key
  
  def self.set_login(login)
    m = get_login
    m = Message.new :context => 'login', :key => 'login' if m.nil?
    m.content = crypt(login)
    m.save
  end
    
  def self.check_login(login)
    crypt(login) == get_login.content
  end
  
  def self.crypt(string)
    Digest::SHA1.hexdigest(SALT + string) 
  end
  
  def self.to_csv
    puts 'context,key,content'
    find(:all, :order => 'context, position').each do |m| 
      puts "#{m.context},\"#{m.key}\",\"#{m.content.gsub(/\"/, "\"\"")}\""
    end
    true
  end
  
private
  
  def self.get_login
    find :first, :conditions => ["context = 'login' AND key = 'login'"]
  end
  
end
