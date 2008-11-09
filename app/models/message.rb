class Message < CachedModel
  
  CONTEXT_HELP = 'help'
  CONTEXT_FAQ = 'faq'
  CONTEXTS = [CONTEXT_HELP, CONTEXT_FAQ]
  
  validates_uniqueness_of :key
  validates_presence_of :key
  
end
