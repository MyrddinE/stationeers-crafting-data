require "json"
require "pretty_print"
require "./stationeers"

json = File.read("Stationeers.json")
parsed = JSON.parse(json)

gd = GameData.new

gd.import parsed
puts "Types: #{types.size}"

items = Item.import(parsed["Item"].as_h)
# items = Hash(String, Item).new
# parsed["Item"].as_h.each do |i|
#   slot = i[1]["Slot"]? ? i[1]["Slot"].as_s : nil
#   id = i[1]["Id"]? ? i[1]["Id"].as_s : nil

#   t = i[1]["Type"]?

#   if t
#     items[i[0]] = Item.new(
#       i[0],
#       types[t.as_s],
#       slot,
#       id
#     )
#   end
# end
puts "Items: #{items.size}"
puts "Ingots: #{items.select {|i| items[i].slot == Slot::Ingot}.size}"

recipes = Recipe.import(parsed["Recipe"].as_h)
# recipes = Hash(String, Recipe).new
# parsed["Recipe"].as_h.each do |r|
#   name = r[0]
#   prop = r[1]
#   n = prop["Note"]?
#   note = n ? n.as_s : nil

#   if prop["Tool"]? && prop["Result"]?
#     tool = items[prop["Tool"].as_s]
#     result = items[prop["Result"].as_s]
#     recipe = Recipe.new(
#       name,
#       tool,
#       result,
#       note
#     )
#     recipes[name] = recipe
#     tool.crafts[recipe] = nil;
#     result.created_by[recipe] = 1.0;
#   end
# end
puts "Recipes: #{recipes.size}"


# parsed["Ingredient"].as_h.each do |r|
#   id = r[0]
#   prop = r[1]

#   if prop["Recipe"]? && prop["Quantity"]? && prop["Item"]?
#     name = prop["Recipe"].to_s

#     recipe = recipes[name]
#     quantity = prop["Quantity"].as_f
#     i = prop["Item"].as_s
#     if items.has_key?(i)
#       item = items[i]
#       recipe.ingredients[item] = quantity;
#       item.ingredient_for[recipe] = quantity;
#     else
#       puts "                           Missing #{i}"
#     end
#   end
# end
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
