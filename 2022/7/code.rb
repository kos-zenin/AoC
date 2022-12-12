REQUIRED_SPACE = 30000000
TOTAL_SPACE = 70000000
FILE = Struct.new(:size, :name, :dir_path)

lines = File.read("input.txt").split("\n")


folders = lines.each.with_object([]).with_object(Hash.new) do |(line, path), memo|
  next if line == "$ ls"
  next if line.match?(/^dir /)

  if line.match?(/^\$ cd /)
    dir = line.split("$ cd ").last

    dir == ".." ? path.pop : (path << dir)

    next
  end

  size, name = line.split(" ")

  _path = path.dup

  path.size.times do |i|
    __path = _path[0..i]

    memo[__path] ||= []
    memo[__path] << FILE.new(size.to_i, name, _path)
  end

  memo
end

part1 = folders.select { |_, files| files.sum(&:size) <= 100000 }.sum { |_, files| files.sum(&:size) }

to_free_up = REQUIRED_SPACE - (TOTAL_SPACE - folders[["/"]].sum(&:size))

part2 = folders.select { |_, files| files.sum(&:size) >= to_free_up }.sort_by { |_, files| files.sum(&:size) }.fi
rst[1].sum(&:size)

puts [part1, part2]
