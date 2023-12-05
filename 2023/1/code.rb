filename = ENV["TEST"] ? "test.txt" : "input.txt"
lines = File.read(filename).split("\n")

TEXT_TO_DIGIT_MAPPING = {
  "one" => 1,
  "two" => 2,
  "three" => 3,
  "four" => 4,
  "five" => 5,
  "six" => 6,
  "seven" => 7,
  "eight" => 8,
  "nine" => 9
}.freeze


result = lines.sum do |line|
  digit1 = line.gsub(/#{TEXT_TO_DIGIT_MAPPING.keys.join("|")}/) { |k| TEXT_TO_DIGIT_MAPPING[k] }.gsub(/[^0-9]/, "").split("").first
  digit2 = line.reverse.gsub(/#{TEXT_TO_DIGIT_MAPPING.keys.map(&:reverse).join("|")}/) { |k| TEXT_TO_DIGIT_MAPPING[k.reverse] }.gsub(/[^0-9]/, "").split("").first

  [digit1, digit2].join.to_i
end

puts result
