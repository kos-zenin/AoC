require './../../window'
require 'set'

ELEVATIONS = ("a".."z").map.with_index { |a, i| [a, i]  }.to_h.merge("S" => 0, "E" => 25)
LOWEST_POINTS = []

POINT = Struct.new(:x, :y, :z, keyword_init: true) do
  def ==(other)
    return false if other.nil?

    self.x == other.x && self.y == other.y
  end

  def can_go?(other)
    self.z >= other.z - 1
  end

  def decorate
    [x, y].join("x")
  end

  def elevation
    @elevation ||= ELEVATIONS.key(z)
  end

  def serialize
    [x, y]
  end

  def all_moves
    @all_moves ||= [
      HEIGHTMAP[y][x + 1],  # right
      y > 0 ? HEIGHTMAP[y - 1][x] : nil, # up
      x > 0 ? HEIGHTMAP[y][x - 1] : nil, # left
      Array(HEIGHTMAP[y + 1])[x], # down
    ]
  end

  def moves_up
    @moves ||= all_moves.compact.select { self.can_go?(_1) }
  end

  def moves_down
    @moves ||= all_moves.compact.select { _1.can_go?(self) }
  end
end

HEIGHTMAP = File.read(ARGV[0] == "test" ? "input1.txt" : "input.txt").split("\n").map.with_index do |row, y|
  row.split("").map.with_index do |cell, x|
    START = POINT.new(x: x, y: y, z: ELEVATIONS[cell]) if cell == "S"
    FINISH = POINT.new(x: x, y: y, z: ELEVATIONS[cell]) if cell == "E"

    point = POINT.new(x: x, y: y, z: ELEVATIONS[cell])

    LOWEST_POINTS << point if point.z == 0

    point
  end
end

NODE = Struct.new(:point, :visited, :distance, keyword_init: true)

NODES = {}
START_NODE = NODE.new(point: FINISH, visited: true, distance: 0)
NODES[FINISH.serialize] = START_NODE

NODES_TO_VISIT = [START_NODE]

def calculate_distances(node, end_points:)
  print_heightmap(node: node)

  node.point.moves_down.each do |child_point|
    _node = NODES[child_point.serialize]

    _node ||= NODE.new(point: child_point)
    _node.distance = [_node.distance, node.distance + 1].compact.min
    NODES[child_point.serialize] = _node
  end

  node.point.moves_down.each do |child_point|
    _node = NODES[child_point.serialize]
    next if _node&.visited

    NODES_TO_VISIT << _node unless end_points.include?(child_point)
    NODES_TO_VISIT.uniq!
  end

  node.visited = true
end

def print_heightmap(map: HEIGHTMAP, node:)
  with_window do |win|
    map.each do |row|
      row.each do |p|
        if NODES[p.serialize]&.visited
          win.addtext(text: p.elevation, color: :red)
        else
          win.addtext(text: p.elevation)
        end
      end
      win.new_line
    end

    win.new_line
    win.addtext(text: "Part 1: #{NODES[START.serialize]&.distance}", color: :green, finish_line: true)
    win.addtext(text: "Part 2: #{node.distance}", color: :green, finish_line: true)

    win.refresh(redraw: true)
  end
end

NODES_TO_VISIT.each { calculate_distances(_1, end_points: LOWEST_POINTS) }

lowest_point = LOWEST_POINTS.min_by { NODES[_1.serialize]&.distance || 100000 }

print_heightmap(node: NODES[lowest_point.serialize])

with_window do |win|
  win.refresh(redraw: false)
  win.getch
end
