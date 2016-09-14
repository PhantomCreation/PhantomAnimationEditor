require_relative '../phantom_animation_editor.rb'

# Animation frame.
class PhantomAnimationEditor::Frame < Gtk::Frame
  THUMBNAIL_SIZE = 100
  attr_accessor :filename, :pixbuf

  def initialize(filename, parent)
    super()
    @filename = filename
    @parent = parent

    image = create_thumbnail
    @pixbuf = image.pixbuf

    create_image_button(image)
    create_spinner
    create_delete_button

    add(create_box)
  end

  def create_thumbnail
    image = Gtk::Image.new(file: @filename)
    unless image.pixbuf.nil?
      if image.pixbuf.width > THUMBNAIL_SIZE || image.pixbuf.height > THUMBNAIL_SIZE
        image.pixbuf = resize(image.pixbuf, THUMBNAIL_SIZE)
      end
    end
    image
  end

  def resize(pixbuf, size)
    if pixbuf.width >= pixbuf.height
      scale = pixbuf.height.to_f / pixbuf.width.to_f
      pixbuf = pixbuf.scale(size, size * scale, GdkPixbuf::InterpType::BILINEAR)
    else
      scale = pixbuf.width.to_f / pixbuf.height.to_f
      pixbuf = pixbuf.scale(size * scale, size, GdkPixbuf::InterpType::BILINEAR)
    end
    pixbuf
  end

  def create_image_button(image)
    @image_button = Gtk::Button.new
    @image_button.set_relief(Gtk::ReliefStyle::NONE)
    @image_button.add(image)
    @image_button.signal_connect('clicked') do
      @parent.focus(self)
    end
  end

  def create_spinner
    adjustment = Gtk::Adjustment.new(100, 1, 999, 1, 1, 0)
    @delay_spinner = Gtk::SpinButton.new(adjustment, 1, 0)
  end

  def create_delete_button
    @delete_button = Gtk::Button.new(label: 'Delete')
    @delete_button.signal_connect('clicked') do
      @parent.delete(self)
    end
  end

  def create_box
    box = Gtk::Box.new(:vertical)
    box.pack_start(@image_button, expand: true, fill: false, padding: 10)
    box.pack_start(@delay_spinner, expand: false, fill: false)
    box.pack_start(@delete_button, expand: false, fill: false)
    box
  end

  def delay
    @delay_spinner.value
  end

  def set_delay(value)
    @delay_spinner.set_value(value)
  end
end
