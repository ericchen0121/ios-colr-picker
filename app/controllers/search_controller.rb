class SearchController < UIViewController
  def viewDidLoad
    super

    self.title = "Search"

    self.view.backgroundColor = UIColor.whiteColor

    # boilerplate textfield code
    @text_field = UITextField.alloc.initWithFrame [[0,0], [160,26]]
    @text_field.placeholder = "#abcabc"
    @text_field.textAlignment = UITextAlignmentCenter
    @text_field.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters
    @text_field.borderStyle = UITextBorderStyleRoundedRect
    @text_field.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 100)
    self.view.addSubview @text_field

    @search = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @search.setTitle("Search", forState:UIControlStateNormal)
    @search.setTitle("Loading", forState:UIControlStateDisabled)
    @search.sizeToFit
    @search.center = CGPointMake(self.view.frame.size.width / 2, @text_field.center.y + 30)
    self.view.addSubview @search

    @search.when(UIControlEventTouchUpInside) do
      @search.enabled = false
      @text_field.enabled = false

      hex = @text_field.text
      hex = hex[1..-1] if hex[0] == "#"
      p "the hex is " + hex.to_str

      Color.find(hex) do |color|
        # adding in appropriate callback if we get an invalid color
        if color.nil?
          #change the button text if no color found thru API
          @search.setTitle("None :(", forState: UIControlStateNormal)
        else
          @search.setTitle("Search", forState: UIControlStateNormal)
          self.open_color(color)
        end

        @search.enabled = true
        @text_field.enabled = true
      end
    end
  end

  def open_color(color)
    p "Opening #{color}"

    self.navigationController.pushViewController(ColorController.alloc.initWithColor(color), animated:true)
  end

end