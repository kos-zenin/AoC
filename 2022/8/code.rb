map = File.read("input.txt").split("\n").map { _1.split("") }
tmap = map.transpose

height = map.size
width = map.first.size

visible = 0
scenic_scores = []

height.times do |h|
  width.times do |w|
    tree_height = map[h][w]

    trees_to_the_edge = [
      map[h][0...w].reverse,
      map[h][(w + 1)..-1],
      tmap[w][0...h].reverse,
      tmap[w][(h + 1)..-1]
    ]

    is_visible = trees_to_the_edge.map { |a| a.all? { |t| t < tree_height } }

    scenic_scores << trees_to_the_edge.map { |arr| arr.inject(0) { |acc, t| acc = acc + 1; break acc if t >= tree_height; acc } }.reject(&:zero?).inject(:*)

    visible = visible + 1 if is_visible
  end
end

puts [visible, scenic_scores.compact.max]
