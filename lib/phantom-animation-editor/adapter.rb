require 'phantom_svg'
require 'fileutils'
require_relative 'frame_list.rb'
require_relative 'frame.rb'

class PhantomAnimationEditor::Adapter
  def initialize
  end

  def import(frame_list, filename)
    # TODO:
    # @apngasm.reset
    # apngframes = @apngasm.disassemble(filename)
    # filename = File.basename(filename, '.png')
    # new_frames = []

    # apngframes.each_with_index do |apngframe, i|
    #   new_frames << PhantomAnimationEditor::Frame.new("#{filename}_#{i}.png", frame_list, apngframe)
    # end

    # new_frames
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
  end

  def check_filename(filename)
    # TODO: 保存時のファイル拡張子の設定、制限がUIでできないかどうか確認
    filename = if filename.include?('.svg') || filename.include?('.png')
                 filename
               else
                 "#{filename}.svg"
               end
  end
end