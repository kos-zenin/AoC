require 'yaml'

ITEM = Struct.new(:level)

MONKEY = Struct.new(:items, :expression, :divisible, :test_true, :test_false, :items_inspected, :gets_bored, :all_divisible, keyword_init: true) do
  def add_item(item)
    items.push(item)
  end

  def inspect_item(item)
    new_level = eval(self.expression.gsub("old", item.level.to_s))

    item.level = all_divisible ? (new_level % all_divisible) : new_level

    self.items_inspected = self.items_inspected + 1

    bore(item) if gets_bored
  end

  def bore(item)
    item.level = item.level / 3
  end

  def pass_items
    while items.length > 0 do
      item = items.pop

      inspect_item(item)

      to_monkey_name = item.level % divisible.to_i == 0 ? test_true : test_false

      yield item, to_monkey_name
    end
  end
end

monkeys = {}
monkeys2 = {}

input = YAML.load_file("input.txt")

input.each do |name, options|
  monkeys[name.downcase] = MONKEY.new(
    items: Array(options["Starting items"].to_s.split(", ")).map { ITEM.new(_1.to_i) },
    expression: options["Operation"].split(" = ").last,
    divisible: options["Test"].split("divisible by ").last,
    test_true: options["If true"].split("throw to ").last,
    test_false: options["If false"].split("throw to ").last,
    items_inspected: 0,
    gets_bored: true
  )
end

all_divisible = monkeys.values.map(&:divisible).map(&:to_i).inject(:*)

input.each do |name, options|
  monkeys2[name.downcase] = MONKEY.new(
    items: Array(options["Starting items"].to_s.split(", ")).map { ITEM.new(_1.to_i) },
    expression: options["Operation"].split(" = ").last,
    divisible: options["Test"].split("divisible by ").last,
    test_true: options["If true"].split("throw to ").last,
    test_false: options["If false"].split("throw to ").last,
    items_inspected: 0,
    gets_bored: false,
    all_divisible: all_divisible
  )
end

20.times do
  monkeys.each do |name, monkey|
    monkey.pass_items do |item, to_monkey_name|
      monkeys[to_monkey_name].add_item(item)
    end
  end
end

10000.times do |i|
  monkeys2.each do |name, monkey|
    monkey.pass_items do |item, to_monkey_name|
      monkeys2[to_monkey_name].add_item(item)
    end
  end
end

part1 = monkeys.values.sort_by(&:items_inspected).last(2).map(&:items_inspected).inject(:*)
part2 = monkeys2.values.sort_by(&:items_inspected).last(2).map(&:items_inspected).inject(:*)

puts [part1, part2].inspect
