moves = File.read("input.txt").split("\n").map { _1.split(" ") }

POINT = Struct.new(:x, :y)

ROPE = Struct.new(:knots) do
  def head
    knots.first
  end

  def tail
    knots.last
  end
end

rope = ROPE.new([POINT.new(0, 0), POINT.new(0, 0)])
rope2 = ROPE.new([POINT.new(0, 0), POINT.new(0, 0), POINT.new(0, 0), POINT.new(0, 0), POINT.new(0, 0), POINT.new(0, 0), POINT.new(0, 0), POINT.new(0, 0), POINT.new(0, 0), POINT.new(0, 0)])

visits = {}
visits2 = {}

def move(rope:, direction:)
  rope.head.x = rope.head.x - 1 if direction == "L"
  rope.head.x = rope.head.x + 1 if direction == "R"
  rope.head.y = rope.head.y + 1 if direction == "D"
  rope.head.y = rope.head.y - 1 if direction == "U"

  rope.knots.each_cons(2) do |(h, t)|
    if h.x - t.x > 1
      t.x = t.x + 1

      t.y = t.y + 1 if h.y > t.y
      t.y = t.y - 1 if h.y < t.y
    elsif t.x - h.x > 1
      t.x = t.x - 1

      t.y = t.y + 1 if h.y > t.y
      t.y = t.y - 1 if h.y < t.y
    elsif h.y - t.y > 1
      t.y = t.y + 1

      t.x = t.x + 1 if h.x > t.x
      t.x = t.x - 1 if h.x < t.x
    elsif t.y - h.y > 1
      t.y = t.y - 1

      t.x = t.x + 1 if h.x > t.x
      t.x = t.x - 1 if h.x < t.x
    end
  end

  rope
end

moves.each do |direction, count|
  count.to_i.times do
    rope = move(rope: rope, direction:)
    visits[[rope.tail.x, rope.tail.y]] = true

    rope2 = move(rope: rope2, direction:)
    visits2[[rope2.tail.x, rope2.tail.y]] = true
  end
end

puts [visits.keys.count, visits2.keys.count]
