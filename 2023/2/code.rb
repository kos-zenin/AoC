filename = ENV["TEST"] ? "test.txt" : "input.txt"
lines = File.read(filename).split("\n")

BAG_STORAGE = {
  "red" => 12,
  "green" => 13,
  "blue" => 14
}.freeze

all_game_sets = lines.map do |line|
  line.gsub(/Game \d+: /, "").split(";").map { |game| game.strip.split(", ").map { |round| round.split(" ").reverse }.to_h }
end

result = all_game_sets
  .map.with_index(1) do |game_set, index|
    possible = game_set.all? { |game| game.all? { |colour, number| number.to_i <= BAG_STORAGE[colour] } }
    possible ? index : 0
  end.sum

puts result


result2 = all_game_sets
  .map do |game_set|
    min_cubes = { "red" => 0, "green" => 0, "blue" => 0 }
    game_set.each { |game| game.each { |colour, number| min_cubes[colour] = [min_cubes[colour], number.to_i].max } }

    min_cubes.values.inject(&:*)
  end.sum

puts result2
