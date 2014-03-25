class Tag
  PROPERTIES = ["timestamp", "id", "name"]
  PROPERTIES.each do |prop|
    attr_accessor prop
  end

  def initialize(properties={})
    properties.each do |k,v|
      PROPERTIES.member? k.to_sym
      self.send((k.to_s + "=").to_s, v)
    end
  end
end