require 'curses'
require 'forwardable'

class Window
  extend Forwardable

  def_delegators :@win, :<<, :getch

  attr_reader :win

  COLOR_PAIRS = {
    red: Curses.color_pair(1),
    green: Curses.color_pair(2)
  }.freeze

  def initialize
    Curses.init_screen
    Curses.crmode
    Curses.start_color
    Curses.init_pair(1, 1, 0) # red
    Curses.init_pair(2, 2, 0) # green

    @win = Curses::Window.new(0, 0, 1, 2)
  end

  def addtext(text: nil, color: nil, finish_line: false, width: text.length)
    color = COLOR_PAIRS[color]

    if text
      text = "%-#{width}.#{width}s" % text.to_s if width

      if color
        win.attron(color) { win << text }
      else
        win << text
      end
    end

    new_line if finish_line
  end

  def new_line
    win << "\n"
  end

  def refresh(redraw: true)
    win.setpos(0, 0) if redraw
    win.refresh
  end
end

def with_window
  @win ||= Window.new

  yield @win if block_given?

  @win
end
