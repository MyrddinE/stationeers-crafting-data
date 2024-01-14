require "json"
require "pretty_print"
require "./stationeers"

json = File.read("Stationeers.json")
parsed = JSON.parse(json)

gd = GameData.new
gd.import parsed
puts "Types: #{types.size}"
puts "Items: #{items.size}"
puts "Ingots: #{items.select {|i| items[i].slot == Slot::Ingot}.size}"
puts "Recipes: #{recipes.size}"
puts "Ingredients: #{recipes.sum {|i| i[1].ingredients.size}}"

parsed["Byproduct"].as_h.each do |r|
  id = r[0]
  prop = r[1].as_h

  if prop["Recipe"]? && prop["Quantity"]? && prop["Item"]?
    name = prop["Recipe"].to_s

    recipe = recipes[name]
    quantity = prop["Quantity"].as_f
    item = items[prop["Item"].as_s]

    recipe.byproducts[item] = quantity;
    item.created_by[recipe] = quantity;
  end
end
puts "Results: #{recipes.sum {|i| i[1].byproducts.size + 1}}"

parsed["ToolAlternate"].as_h.each do |ta|
  tool_name = ta[0]
  prop = ta[1]

  if prop["Basic"]? && prop["Speed"]? && prop["Energy"]?
    tool = items[tool_name]
    speed = prop["Speed"].as_f
    energy = prop["Energy"].as_f

    tool.basic_tool = items[prop["Basic"].to_s]
    tool.speed = speed
    tool.energy = energy
  end
end

#items.select {|i| items[i].slot == Slot::Ingot}.each {|i| puts i[1].summary}
#items.select {|i| items[i].itype == types["Element"]}.each {|i| puts i[1].summary}
puts items["Autolathe [T1]"].summary
puts items["Electronics Printer [T1]"].summary
puts items["Electronics Printer [T2]"].summary
