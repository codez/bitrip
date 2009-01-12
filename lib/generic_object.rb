class GenericObject
  
  attr_reader :attrs
  
  def initialize(attrs)
    @attrs = attrs
  end
  
  def [](value)
    @attrs[value]
  end
  
  # special treatment because inherited...
  def type
    include?(:type) ? attr_value(:type) : super
  end
  
  def method_missing(symbol, *args)
    if include? symbol
      attr_value symbol
    else
      #super symbol, args
      []
    end  
  end
  
  def respond_to?(symbol, include_private = false)
    #include?(symbol) || super(symbol, include_private)
    true
  end
  
  def attr_value(symbol)
    val = @attrs[symbol.to_s]
    val = val.collect{ |v| GenericObject.new v } if val.kind_of? Array
    val = [GenericObject.new val] if val.is_a? Hash
    val
  end
  
  def include?(symbol)
    @attrs.include?(symbol.to_s)
  end
  
end