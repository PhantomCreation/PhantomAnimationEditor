require 'phantom_svg'

class PhantomAnimationEditor::FrameList
  attr_accessor :frame_hbox, :cur, :list, :phantom_svg

  def initialize(frame_hbox)
    @frame_hbox = frame_hbox
    @list = []
    @phantom_svg = Phantom::SVG::Base.new
  end

  def <<(data)
    @list << data
    @cur = @list.size - 1
    @phantom_svg.add_frame_from_file(data.filename) if File.exist?(data.filename)
  end

  def size
    @list.size
  end

  def filename(position = nil)
    return @list[@cur].filename if position.nil?
    return nil if position > @list.size
    return @list[position].filename
  end

  def pixbuf(position = nil)
    return @list[@cur].pixbuf if position.nil?
    return nil if position > @list.size
    return @list[position].pixbuf
  end

  def delay(position = nil)
    return @list[@cur].delay if position.nil?
    return nil if position > @list.size
    return @list[position].delay
  end

  def swap(old_position, new_position)
    case new_position
    when 0 then
      insert_first(@list, old_position)
      insert_first(@phantom_svg.frames, old_position)
    when @list.size - 1 then
      insert_last(@list, old_position)
      insert_last(@phantom_svg.frames, old_position)
    else
      swap_pos(@list, old_position, new_position)
      swap_pos(@phantom_svg.frames, old_position, new_position)
    end
  end

  def insert_first(list, old_position)
    list.insert(0, list[old_position])
    list.delete_at(old_position + 1)
  end

  def insert_last(list, old_position)
    list << list[old_position]
    list.delete_at(old_position)
  end

  def swap_pos(list, old_position, new_position)
    list[old_position], list[new_position] = list[new_position], list[old_position]
  end

  def delete(child)
    @phantom_svg.frames.delete_at(@list.find_index(child))
    @list.delete(child)
    @frame_hbox.remove(child)

    @cur -= 1 unless @cur == 0
    if @list.size == 0
      $preview.set_stock(Gtk::Stock::MISSING_IMAGE)
    else
      $preview.set_pixbuf(@list[@cur].pixbuf)
    end
  end

  def delete_at(index)
    child = @list[index]
    delete(child)
  end

  def delete_all
    @list.size.times do
      child = @list[0]
      @list.delete(child)
      @frame_hbox.remove(child)
    end
    @phantom_svg.reset
    @cur = 0
    $preview.set_stock(Gtk::Stock::MISSING_IMAGE)
  end

  def focus(child)
    @cur = @list.find_index(child)
    $preview.set_pixbuf(@list[@cur].pixbuf)
  end

  def view_reload
    @list.each { |frame| @frame_hbox.remove(frame) }
    @list.each do |frame|
      @frame_hbox.pack_start(frame, expand: false, fill: false, padding: 10)
    end
  end
end
