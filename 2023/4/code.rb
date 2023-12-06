filename = ENV["TEST"] ? "test.txt" : "input.txt"
lines = File.read(filename).split("\n")

cards = lines.map { |line| line.gsub(/Card\s+\d+: /, "").split(" | ").map { |line_part| line_part.split(" ").map(&:strip).map(&:to_i) } }

result = cards.inject(0) do |total_prize, (left, right)|
  winning_numbers = (left & right).count

  if winning_numbers > 0
    total_prize = total_prize + (2 ** (winning_numbers - 1))
  end

  total_prize
end

puts result

cards_count = lines.each.with_object({}).with_index { |(l, m), i| m[i] = 1 }

cards_count.each do |index, count|
  left, right = cards[index]
  winning_numbers = (left & right).count

  (index + 1..index + winning_numbers).each { |i| cards_count[i] += count if cards_count[i] }
end

puts cards_count.values.sum
