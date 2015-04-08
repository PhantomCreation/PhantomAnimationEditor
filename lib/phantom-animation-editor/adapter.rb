require 'phantom_svg'
require 'rapngasm'
require 'fileutils'
require_relative 'frame_list.rb'
require_relative 'frame.rb'

class PhantomAnimationEditor::Adapter
  def initialize
    # TODO: apng or アニメーションsvgをインポートしてエクスポートしようとすると
    #       ファイルが必要になるため、作業用フォルダを作成して保存している。
    @tmp_dir = "#{File.dirname(__FILE__)}/tmp"
    Dir.mkdir(@tmp_dir) unless File.exist?(@tmp_dir)
  end

  def import(frame_list, filename)
    new_frames = []
    @loader = Phantom::SVG::Base.new
    @loader.add_frame_from_file(filename)

    @loader.frames.each_with_index do |frame, i|
      tmp_filename = "#{@tmp_dir}/#{Time.now.to_i}_#{i}.svg"
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

    @loader = Phantom::SVG::Base.new
    set_frames
    save
  end

  def set_frames
    @frames.each do |frame|
      @loader.add_frame_from_file(frame.filename)
      @loader.frames[-1].duration = frame.delay * 0.001
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