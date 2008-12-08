class GenericObject
  
  attr_reader :attrs
  
  def initialize(attrs)
    @attrs = attrs
  end
  
  def [](value)
    @attrs[value]
  end
  
  def method_missing(symbol, *args)
    if include? symbol
      val = @attrs[symbol.to_s]
      val = val.collect{ |v| GenericObject.new v } if val.kind_of? Array
      val
    else
      super symbol, args
    end  
  end
  
  def respond_to?(symbol, include_private = false)
    include?(symbol) || super(symbol, include_private)
  end
  
  def include?(symbol)
    @attrs.include?(symbol.to_s)
  end
  
end