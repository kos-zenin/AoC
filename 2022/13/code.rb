def bigger?(second, first)
  Array(first).each.with_index do |item1, index|
    item2 = Array(second)[index]
    return false if item2.nil?

    next if Array(item1) == Array(item2)

    return item2 > item1 if item1.is_a?(::Integer) && item2.is_a?(::Integer)

    return bigger?(item2, item1)
  end

  Array(second).size > Array(first).size
end

pairs = File.read(ARGV[0] == "test" ? "input1.txt" : "input.txt").split("\n").each_slice(3).map { |(packet1, packet2, _)| [eval(packet1), eval(packet2)]  }

part1 = pairs.map.with_index(1) do |(packet1, packet2), index|
  bigger?(packet2, packet1) ? index : 0
end.sum

part2 = pairs.each.with_object([]) { |(p1, p2), m| m << p1; m << p2 }
  .then { _1 << [[2]]; _1 << [[6]] }
  .sort { |packet1, packet2| bigger?(packet2, packet1) ? 0 <=> 1 : 1 <=> 0 }
  .each { puts _1.inspect }
  .map.with_index(1) { |packet, index| index if packet == [[2]] || packet == [[6]] }
  .compact.inject(:*)

puts [part1, part2].inspect
