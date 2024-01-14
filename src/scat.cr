# Stationeers Crafting Automation Tool
# (c)2024 Myrddin Emrys
# Licensed under CC BY-SA

require "json"
require "pretty_print"
require "./stationeers"

begin
    json = File.read("Stationeers.json")
rescue
    puts "Missing data, JSON not found or unreadable in current directory."
end
begin
    parsed = JSON.parse(json)
rescue
    puts "Data file not a valid JSON document."
end

gd = GameData.new
begin
    gd.import parsed
rescue ex
    puts "JSON file not in the require format: #{ex.message}"
    exit
end
puts "Types: #{gd.types.size}"
puts "Items: #{gd.items.size}"
puts "Ingots: #{gd.items.select {|k,v| gd.items[k].slot == Slot::Ingot}.size}"
puts "Recipes: #{gd.recipes.size}"
puts "Ingredients: #{gd.recipes.sum {|i| i[1].ingredients.size}}"
puts "Results: #{gd.recipes.sum {|i| i[1].byproducts.size + 1}}"
list = gd.items.select {|k,v| gd.items[k].itype == gd.get_type "Machine"}
list.each do |i|
    item = gd.get_item i
    if item
        puts item.summary
    end
end