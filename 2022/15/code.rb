require 'set'

POINT = Struct.new(:x, :y, keyword_init: true)

DISTANCES = {}

SENSOR = Struct.new(:sensor, :beacon, keyword_init: true) do
  def distance
    @distance ||= calculate_distance
  end

  def calculate_distance
    (sensor.x - beacon.x).abs + (sensor.y - beacon.y).abs
  end

  def x_covered(dy)
    remaining_x = distance - (sensor.y - dy).abs

    remaining_x <= 0 ? [] : ((sensor.x - remaining_x)..(sensor.x + remaining_x))
  end

  def y_covered(dx)
    remaining_y = distance - (sensor.y - dx).abs

    remaining_y <= 0 ? [] : ((sensor.y - remaining_y)..(sensor.y + remaining_y))
  end
end

sensors = File.read(ARGV[0] == "test" ? "input1.txt" : "input.txt").split("\n").map do |line|
  sensor, beacon = line.split(":")
  sx, sy = sensor.scan(/-?\d+/)
  bx, by = beacon.scan(/-?\d+/)

  sensor = POINT.new(x: sx.to_i, y: sy.to_i)
  beacon = POINT.new(x: bx.to_i, y: by.to_i)

  SENSOR.new(sensor:, beacon:)
end

min_x = 0
max_x = 1000
max_distance = 1

y = ARGV[0] == "test" ? 10 : 2000000

sensors.each do |s|
  min_x = [s.sensor.x, s.beacon.x, min_x].min
  max_x = [s.sensor.x, s.beacon.x, max_x].max
  max_distance = [s.distance, max_distance].max
end

min_x = min_x - max_distance
max_x = max_x + max_distance

beacon_xs = sensors.map { _1.beacon.x if _1.beacon.y == y }.compact.uniq

part1 = (sensors.flat_map { _1.x_covered(y).to_a }.uniq - beacon_xs).size


max_coordinate = ARGV[0] == "test" ? 20 : 4000000

distress_point = nil #POINT.new(x: 1, y: 1)

all_coordinates = (0..max_coordinate)

def merge_ranges(all_ranges)
  all_ranges.inject([0..0]) do |ranges, srange|
    new_ranges = []

    ranges = ranges.map do |range|
      if srange.size > 0 && ((srange.min <= range.max && srange.max > range.min) || (range.min <= srange.max && range.max > srange.min))
        ([srange.min, range.min].compact.min..[srange.max, range.max].compact.max)
      else
        new_ranges << srange if srange.size > 0

        range
      end
    end

    ranges = ranges + new_ranges
  end.uniq
end

(0..max_coordinate).each do |dy|
  coverage_ranges = merge_ranges(sensors.map { _1.x_covered(dy) })
  coverage_ranges = merge_ranges(coverage_ranges)

  next if coverage_ranges.any? { _1.cover?(all_coordinates) }

  dx = (all_coordinates.to_a - sensors.flat_map { _1.x_covered(dy).to_a }.uniq).last

  break distress_point = POINT.new(x: dx, y: dy) if dx
end

part2 = distress_point.x * 4000000 + distress_point.y

puts [part1, part2].inspect
