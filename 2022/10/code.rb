commands = File.read("input.txt").split("\n")

INTERESTING_TICKS = [20, 60, 100, 140, 180, 220]

ticks = []
tick = 0

crt = []

commands.each do |cmd|
  (cmd == "noop" ? 1 : 2).times do
    sprite_middle = ticks[tick] || 1
    crt[tick] = [sprite_middle - 1, sprite_middle, sprite_middle + 1].include?(tick % 40) ? "X" : "."

    tick = tick + 1

    ticks[tick] = ticks[tick - 1] || 1
  end

  next if cmd == "noop"

  value_to_add = cmd.gsub("addx ", "")

  ticks[tick] = ticks[tick - 1] + value_to_add.to_i

end

part1 = INTERESTING_TICKS.sum { |t| ticks[t - 1] * t }

puts part1

crt.each_slice(40) { puts _1.join }
