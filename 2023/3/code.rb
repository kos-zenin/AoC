filename = ENV["TEST"] ? "test.txt" : "input.txt"
lines = File.read(filename).split("\n")
matrix = lines.map { |line| line.split("") }

DIGITS = (0..9).to_a.map(&:to_s)
NON_SYMBOLS = [DIGITS, "."].flatten
NUMBER = Struct.new(:value, :y, :x1, :x2, keyword_init: true)

numbers = []

matrix.each.with_index(0) do |line, y_index|
  _item = "."
  _number = nil

  line.each.with_index(0) do |item, x_index|
    if DIGITS.include?(item.to_s)
      _number ||= NUMBER.new(y: y_index, x1: x_index).tap { numbers << _1 }
      _number.value = [_number.value, item].compact.join
      _number.x2 = x_index if line.size == x_index + 1
    else
      _number.x2 = x_index - 1 if _number
      _item = "."
      _number = nil
    end
  end
end

result = numbers
  .select do |number|
    numbers_around = []
    if number.y > 0
      numbers_around << matrix[number.y - 1][([number.x1 - 1, 0].max)..number.x2 + 1].to_a
    end

    if number.y < matrix.size - 1
      numbers_around << matrix[number.y + 1][([number.x1 - 1, 0].max)..number.x2 + 1].to_a
    end

    numbers_around << matrix[number.y][number.x1 - 1]
    numbers_around << matrix[number.y][number.x2 + 1]

    (numbers_around.compact.flatten - NON_SYMBOLS).any?
  end.sum { |n| n.value.to_i }

puts result

result2 = matrix.map.with_index(0) do |line, y_index|
  line.map.with_index(0) do |item, x_index|
    next if item != "*"

    numbers_around = numbers.select do |number|
      if number.y == y_index
        next true if number.x1 - 1 == x_index || number.x2 + 1 == x_index
      end

      if [y_index - 1, y_index + 1].include?(number.y)
        next true if (([number.x1 - 1, 0].max)..number.x2 + 1).include?(x_index)
      end
    end

    numbers_around.map(&:value).map(&:to_i).inject(&:*) if numbers_around.size == 2
  end
end.flatten.compact.sum

puts result2
