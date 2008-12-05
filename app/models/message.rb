require "digest"
require "digest/sha1"

class Message < ActiveRecord::Base
  
  CONTEXT_HELP = 'help'
  CONTEXT_FAQ = 'faq'
  CONTEXTS = [CONTEXT_HELP, CONTEXT_FAQ]
  
  SALT = 'ch1ch1b00'
  
  validates_uniqueness_of :key
  validates_presence_of :key
  
  def self.get(key)
    c_key = cache_key(key)
    content = CACHE.get c_key
    if content.nil?
      record = Message.find :first, :conditions => ['key = ?', key]
      content = record.nil? ? key : record.content
      CACHE.set c_key, content, MESSAGE_CACHE_TTL
    end
    content
  end
  
  def self.set_login(login)
    m = get('login')
    m = Message.new :context => 'login', :key => 'login' if m == 'login'
    m.content = crypt(login)
    m.save
    m.store_cache
  end
    
  def self.check_login(login)
    crypt(login) == get('login')
  end
  
  def self.crypt(string)
    Digest::SHA1.hexdigest(SALT + string) 
  end
  
  def self.to_csv
    puts 'context,position,key,content'
    find(:all, :order => 'context, position').each do |m| 
      puts "#{m.context},#{position},\"#{m.key}\",\"#{m.content.gsub(/\"/, "\"\"")}\""
    end
    true
  end
    
  def cache_store
    CACHE.set self.class.cache_key(key), content, MESSAGE_CACHE_TTL
  end
  
  def cache_remove
    CACHE.delete self.class.cache_key(key)
  end
  
private
  
  def self.cache_key(key)
    "Message:#{key}"
  end
  
end
