class Color
  PROPERTIES = [:timestamp, :hex, :id, :tags]
  
  PROPERTIES.each do |prop|
    attr_accessor prop
  end

  def initialize(properties = {})
    properties.each do |k, v|
      if PROPERTIES.member? k.to_sym
        self.send((k.to_s + "=").to_s, v)
      end
    end
  end

  # methods to ensure "tags" property is an array of Tag objects
  #define custom getter to return an array if it's empty
  def tags
    @tags ||= []
  end

  #define custom setter to make sure every object in tags will be a Tag object
  def tags=(tags)
    if tags.first.is_a? Hash
      tags = tags.collect { |tag| Tag.new(tag) }
    end

    tags.each { |tag|
      if not tag.is_a? Tag
        raise "Wrong class for attempted tag #{tag.inspect}"
      end
    }

    @tags = tags
  end

  # class method! ...
  # block argument is for callbacks
  def self.find(hex, &block)
    BW::HTTP.get("http://www.colr.org/json/color/#{hex}") do |response|
      # p response.body.to_str # awesome_print it
      # parses the object into a ruby hash
      result_data = BW::JSON.parse(response.body.to_str)
      color_data = result_data["colors"][0]

      #create a new color, setup because match between API and model.
      color = Color.new(color_data)

      #handle the API's return of a non-existent entity
      if color.id.to_i == -1
        block.call(nil)
      else
        block.call(color)
      end
      
    end
  end

  def add_tag(tag, &block)
    BW::HTTP.post("http://www.colr.org/js/color/#{self.hex}/addtag/", payload: {tags:tag}) do |response|
      if response.ok?
        block.call(tag)
      else
        block.call(nil)
      end
    end
  end
end