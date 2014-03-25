class ColorController < UIViewController
  attr_accessor :color

  def initWithColor(color)
    initWithNibName(nil, bundle:nil) # always call the designated initializer of superclass first
    self.color = color
    self # must also call self when overriding iOS SDK initializer
  end

  def viewDidLoad
    super

    self.title = self.color.hex

    # You must comment out the following line if you are developing on iOS < 7.
    self.edgesForExtendedLayout = UIRectEdgeNone

    # A light grey background to separate the Tag table from the Color info
    @info_container = UIView.alloc.initWithFrame [[0, 0], [self.view.frame.size.width, 110]]
    @info_container.backgroundColor = UIColor.lightGrayColor
    self.view.addSubview @info_container

    # A visual preview of the actual color
    @color_view = UIView.alloc.initWithFrame [[10, 10], [90, 90]]
    # String#to_color is another handy BubbbleWrap addition!
    @color_view.backgroundColor = "3b5998".to_color
    self.view.addSubview @color_view

    # Displays the hex code of our color
    @color_label = UILabel.alloc.initWithFrame [[110, 30], [0, 0]]
    @color_label.text = self.color.hex
    @color_label.sizeToFit
    self.view.addSubview @color_label

    # Where we enter the new tag
    @new_tag_field = UITextField.alloc.initWithFrame [[110, 60], [100, 26]]
    @new_tag_field.placeholder = "new tag"
    @new_tag_field.textAlignment = UITextAlignmentCenter
    @new_tag_field.autocapitalizationType = UITextAutocapitalizationTypeNone
    @new_tag_field.borderStyle = UITextBorderStyleRoundedRect
    self.view.addSubview @new_tag_field

    # Tapping this adds the tag.
    @add = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @add.setTitle("Add", forState:UIControlStateNormal)
    @add.setTitle("Adding...", forState:UIControlStateDisabled)
    @add.setTitleColor(UIColor.lightGrayColor, forState:UIControlStateDisabled)
    @add.sizeToFit
    @add.frame = [[@new_tag_field.frame.origin.x + @new_tag_field.frame.size.width + 10, @new_tag_field.frame.origin.y],
                      @add.frame.size]
    self.view.addSubview(@add)

    # callback for the @add button in the ColorController
    # when user clicks the @add button, it calls back to the ColorsController and runs Color#add_tag
    @add.when(UIControlEventTouchUpInside) do 
      # disable fieldswhen control makes something happen
      @add.enabled = false
      @new_tag_field.enabled = false

      # note how the Color#add_tag takes a block
      # after Color#add_tag runs, it runs refresh()
      self.color.add_tag(@new_tag_field.text) do |tag|
        if tag
          refresh
        else
          @add.enabled = true
          @new_tag_field.enabled = true
          @new_tag_field.text = "Failed :("
        end
      end
    end

    # The table for our color's tags.
    table_frame = [[0, @info_container.frame.size.height],
                  [self.view.bounds.size.width, self.view.bounds.size.height - @info_container.frame.size.height - self.navigationController.navigationBar.frame.size.height]]
    @table_view = UITableView.alloc.initWithFrame(table_frame, style:UITableViewStylePlain)
    self.view.addSubview(@table_view)

    @table_view.dataSource = self #iOS tableview
  end

  def tableView(tableView, numberOfRowsInSection:section) # iOS
    self.color.tags.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    # fetches a previously created cell object marked for reuse
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
    end

    cell.textLabel.text = self.color.tags[indexPath.row].name

    cell
  end

  def refresh
    Color.find(self.color.hex) do |color|
      self.color = color
      @table_view.reloadData
      @add.enabled = true
      @new_tag_field.enabled = true
    end
  end
end