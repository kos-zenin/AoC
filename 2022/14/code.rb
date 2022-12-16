require "./../../window"

SAND_START_POINT_X = 500
SAND_START_POINT_Y = 0

POINT = Struct.new(:x, :y, :z, keyword_init: true) do
  def line_to(other)
    return horizontal_line_to(other) if y == other.y
    return vertical_line_to(other) if x == other.x

    raise "diagonals unsupported"
  end

  def horizontal_line_to(other)
    points = x > other.x ? (other.x..x) : (x..other.x)

    points.map { |_x| MAP[y][_x] }
  end

  def vertical_line_to(other)
    points = y > other.y ? (other.y..y) : (y..other.y)

    points.map { |_y| MAP[_y][x] }
  end

  def z=(new_value)
    self[:z] = new_value if z.nil? || z == "." || z == "+"

    raise "unexpected z assignment" if z != new_value
  end

  def all_moves
    @all_moves ||= [
      Array(MAP[y + 1])[x],
      Array(MAP[y + 1])[x - 1],
      Array(MAP[y + 1])[x + 1]
    ]
  end

  def moves
    all_moves.compact.select { _1.z == "." }
  end

  def rest?
    all_moves.all? { ["#", "+"].include?(_1&.z) }
  end

  def falls_to_eternity?
    all_moves.any? { [nil].include?(_1&.z) }
  end

  def can_fall?
    return false unless z == "+"

    !rest? && moves.first
  end

  def fall
    raise "cannot move" if z != "+"

    self.z = "."
    moves.first.tap { _1.z = "+" }
  end
end

MAP_RULES = File.read(ARGV[0] == "test" ? "input1.txt" : "input.txt").split("\n")

def print_map(map: MAP, xs: (0..520), ys: (0..200), wait: true, redraw: true)
  with_window do |win|
    rows = map[ys]
    win.addtext(text: "-", color: :green, width: 4)
    rows.first[xs].each do |point|
      win.addtext(text: point.x || "-", color: :green, width: 4)
    end

    win.new_line

    rows.each do |row|
      points = row[xs]
      win.addtext(text: points.first.y || "-", color: :green, width: 4)

      points.each do |point|
        win.addtext(text: point.z, width: 4, color: point.z == "+" ? :red : nil)
      end

      win.new_line
    end

    win.refresh(redraw:)
    win.getch if wait
  end
end

MAP = 200.times.map do |y|
  10000.times.map do |x|
    POINT.new(x:, y:, z: ".")
  end
end

def clear_map
  200.times.map do |y|
    10000.times.map do |x|
      MAP[y][x] = POINT.new(x:, y:, z: ".")
    end
  end
end

def build_stones_on_map(map_rules: MAP_RULES)
  ys = []

  map_rules.each do |line|
    line.split(" -> ").each_cons(2) do |start, finish|
      sx, sy = start.split(",")
      fx, fy = finish.split(",")
      start = POINT.new(x: sx.to_i, y: sy.to_i)
      finish = POINT.new(x: fx.to_i, y: fy.to_i)

      ys << sy.to_i
      ys << fy.to_i

      start.line_to(finish).each do |point|
        point.z = "#"
      end
    end
  end

  ys
end

can_fall = true
sands = []
build_stones_on_map

sand = MAP[0][500].tap { _1.z = "+" } # start

while can_fall do
  if sand.falls_to_eternity?
    can_fall = false

    break
  end

  sands << sand if sand.rest?

  if sand.can_fall?
    sand = sand.fall
  else
    sand = MAP[SAND_START_POINT_Y][SAND_START_POINT_X].tap { _1.z = "+" }
  end
end

can_fall2 = true
sands2 = []
clear_map
ys = build_stones_on_map

floor_y = ys.max + 2
MAP[floor_y] = 10000.times.map { |x| POINT.new(x:, y: floor_y, z: "#") }

sand = MAP[0][500].tap { _1.z = "+" } # start

while can_fall2 do
  sands2 << sand if sand.rest?

  if sand.x == SAND_START_POINT_X && sand.y == SAND_START_POINT_Y && sand.rest?
    can_fall2 = false

    break
  end

  if sand.can_fall?
    sand = sand.fall
  else
    sand = MAP[SAND_START_POINT_Y][SAND_START_POINT_X].tap { _1.z = "+" }
  end
end

with_window do |win|
  print_map(map: MAP, xs: (490..510), ys: (0..20), wait: false, redraw: true)

  win.new_line
  win.addtext(text: "Part 1: #{sands.count}", color: :green, finish_line: true)
  win.addtext(text: "Part 2: #{sands2.count}", color: :green, finish_line: true)
  win.getch
end
