require 'cached_model'

memcache_options = {
  :c_threshold => 10_000,
  :compression => true,
  :debug => false,
  :namespace => 'bitrip',
  :readonly => false,
  :urlencode => false
}

CachedModel.ttl = 24
CACHE = MemCache.new memcache_options
CACHE.servers = 'localhost:11211'