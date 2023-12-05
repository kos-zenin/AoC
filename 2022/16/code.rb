require 'set'

MINUTES = 30

VALVE = Struct.new(:name, :flow_rate, :tunnels, keyword_init: true) do
  def next_valves
    @next_valves ||= tunnels.map { VALVES[_1] }
  end
end

VALVES = File.read(ARGV[0] == "test" ? "input1.txt" : "input.txt").split("\n").each.with_object({}) do |line, memo|
  _valves, _tunnels = line.split("; ")

  name = _valves.split("Valve ")[1][0..1]
  flow_rate = _valves.split("rate=")[1].to_i

  tunnels = _tunnels.split("tunnels lead to valves ")[1].split(", ")

  memo[name] = VALVE.new(name:, flow_rate:, tunnels:)
end

OPENABLE_VALVES = VALVES.select { |_, valve| valve.flow_rate > 0 }.values

DISTANCES = {}

def calculate_distance(valve1)
  valves_to_visit = [valve1]

  distances = DISTANCES[valve1.name]

  return distances if DISTANCES[valve1.name]

  DISTANCES[valve1.name] ||= {}

  valves_to_visit.each do |valve|
    valve.next_valves.each do |next_valve|
      next if DISTANCES[valve1.name][next_valve.name]

      DISTANCES[valve1.name][next_valve.name] = DISTANCES[valve1.name][valve.name].to_i + 1

      valves_to_visit << next_valve
    end
  end

  DISTANCES[valve1.name]
end

# def calculate(f_threshold, d_threshold)
#   current_valve = VALVES["AA"]

#   opened_at = {}

#   total_distance = 0

#   while total_distance <= 30
#     calculate_distance(current_valve)

#     next_valves = DISTANCES[current_valve.name]
#       .select { |valve_name, distance| !opened_at.keys.include?(valve_name) && VALVES[valve_name].flow_rate > 0 && (MINUTES - total_distance) > (distance + 2) }
#       .sort_by do |valve_name, distance|
#         valve = VALVES[valve_name]

#         next [100, -valve.flow_rate] if distance > d_threshold
#         next [50, -valve.flow_rate] if valve.flow_rate < f_threshold

#         [distance, -valve.flow_rate]
#       end

#     break unless next_valves.first

#     next_valve_name = next_valves.first.first

#     total_distance = total_distance + DISTANCES[current_valve.name][next_valve_name] + 1
#     opened_at[next_valve_name] = total_distance

#     current_valve = VALVES[next_valve_name]
#   end

#   total = opened_at.sum { |valve_name, minute| VALVES[valve_name].flow_rate * (MINUTES - minute) }

#   total
# end

# part1 = (9..25).flat_map { |f_threshold| (0..7).map { |d_threshold| calculate(f_threshold, d_threshold) } }.max

def open_valves(valves, opened_at, total_minutes: MINUTES)
  current_valve = VALVES["AA"]

  total_distance = 0

  valve_index = 0

  while total_distance <= total_minutes
    calculate_distance(current_valve)

    next_valve_name = valves[valve_index]

    break unless next_valve_name

    total_distance = total_distance + DISTANCES[current_valve.name][next_valve_name] + 1
    opened_at[next_valve_name] = total_distance

    current_valve = VALVES[next_valve_name]

    valve_index = valve_index + 1
  end

  opened_at
end

def run(total_minutes: MINUTES, elephant: false)
  results = []

  openable_valve_names = OPENABLE_VALVES.map(&:name)

  openable_valve_names.permutation do |ordered_valve_names|
    opened_at = {}

    ordered_valve_names, elephant_ordered_valve_names = ordered_valve_names.each_slice((ordered_valve_names.size / 2.0).round).to_a if elephant

    open_valves(ordered_valve_names, opened_at, total_minutes:)

    if elephant
      open_valves(elephant_ordered_valve_names, opened_at, total_minutes:)
    end

    results << opened_at.sum { |valve_name, minute| VALVES[valve_name].flow_rate * (total_minutes - minute) }
  end

  results.max
end

puts Time.now
puts [run, run(total_minutes: 26, elephant: true)].inspect # [1659, 2382]
puts Time.now
