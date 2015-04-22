require 'phantom_svg'
require 'rapngasm'
require 'fileutils'
require 'tmpdir'
require_relative 'frame_list.rb'
require_relative 'frame.rb'

class PhantomAnimationEditor::Adapter
  def initialize
  end

  def import(frame_list, filename)
    new_frames = []
    @loader = Phantom::SVG::Base.new
    @loader.add_frame_from_file(filename)

    Dir.mktmpdir do |dir|
      new_frames = import_frames(dir, frame_list)
    end

    data = {frames: new_frames, phantom_frames: @loader.frames}
    data
  end

  def import_frames(dir, frame_list)
    new_frames = []
    @loader.frames.each_with_index do |frame, i|
      tmp_filename = "#{dir}/#{i}.svg"
      @loader.save_svg_frame(tmp_filename, frame)
      new_frames << PhantomAnimationEditor::Frame.new(tmp_filename, frame_list)
    end
    new_frames
  end

  def export(frame_list, filename, frames_status, loop_status)
    @frames = frame_list.list
    @filename = check_filename(filename)
    @frames_status = frames_status
    @loop_status = loop_status
    @loader = frame_list.phantom_svg

    set_params
    save
  end

  def set_params
    @frames.each_with_index do |frame, i|
      @loader.frames[i].duration = frame.delay * 0.001
    end
    @loader.loops = 1 unless @loop_status
  end

  def save
    if @filename.include?('.svg')
      save_svg
    else
      save_apng
    end

    GC.start
  end

  def save_svg
    @loader.save_svg(@filename)
    save_svg_frames if @frames_status
  end

  def save_svg_frames
    @loader.frames.each_with_index do |frame, i|
      dest = "#{File.dirname(@filename)}/#{File.basename(@filename, '.svg')}"
      FileUtils.mkdir_p(dest) unless File.exist?(dest)
      @loader.save_svg_frame("#{dest}/#{i}.svg", frame)
    end
  end

  def save_apng
    # TODO: macのrubyだと保存時に落ちる
    @loader.save_apng(@filename)
    save_apng_frames if @frames_status
  end

  def save_apng_frames
    # TODO: phantom_svgにapngの各フレームの保存関数がない
    apngasm = APNGAsm.new
    apngasm.disassemble(@filename)
    dest = "#{File.dirname(@filename)}/#{File.basename(@filename, '.png')}"
    FileUtils.mkdir_p(dest) unless File.exist?(dest)
    apngasm.save_pngs(dest)
  end

  def check_filename(filename)
    filename = if filename.include?('.svg') || filename.include?('.png')
                 filename
               else
                 "#{filename}.svg"
               end
  end
end