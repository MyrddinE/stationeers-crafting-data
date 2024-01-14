require "json"
require "./import"

enum Slot : UInt8
  AccessCard
  Appliance
  Back
  Battery
  Belt
  Bottle
  Cartridge
  Circuitboard
  CreditCard
  DataDisk
  Egg
  Filter
  GasCanister
  Glasses
  Helmet
  Ingot
  Item
  LiquidCanister
  Magazine
  Motherboard
  Ore
  ProgrammableChip
  SensorProcessingUnit
  SoundCartridge
  Suit
  Tool
  Uniform
end

class GameData
  property itemtypes, items, recipes, ingredients

  def initialize()
    @itemtypes = Hash(String, ItemType).new
    @items = Hash(String, Item).new
    @recipes = Hash(String, Recipe).new
    @ingredients = Hash(String, Ingredient).new
  end

  def initialize(any : JSON::Any)
    @itemtypes = Hash(String, ItemType).new
    @items = Hash(String, Item).new
    @recipes = Hash(String, Recipe).new
    @ingredients = Hash(String, Ingredient).new
  end
end

class ItemType
  getter name, category, order

  def initialize(
      @name : String,
      @category : String?,
      @order : UInt8
    )
  end

  def self.import(data : Hash(String, JSON::Any))
    hash = Hash(String, ItemType).new

    data.each do |i|
      name = i[0]; prop = i[1].as_h

      category = Import.optional_string(prop,"Category")
      order = Import.uint8(prop,"Order")

      hash[name] = ItemType.new(name, category, order)
    end

    return hash
  end

  def to_s
    @name
  end
end

class Recipe
  getter name, tool, result, note
  property byproducts, ingredients

  def initialize(
      @name : String,
      @tool : Item,
      @result : Item,
      @note : String?,
    )

    @byproducts = Hash(Item, Float64).new
    @ingredients = Hash(Item, Float64).new
  end

  def self.import(data : Hash(String, JSON::Any))
    hash = Hash(String, Recipe).new

    data.each do |i|
      name = i[0]; prop = i[1]

      note = Import.optional_string("Note", prop)
      # t = Import.optional_string("Tool", prop)
      # r = Import.optional_string("Result", prop)
      if t && r
        # tool =
        # result =
        recipe = Recipe.new(name, tool, result, note)
        hash[name] = recipe
      end
    end

    return hash
  end

  def to_s
    @name
  end

  def summary
<<-SUMMARY
#{self.to_s}
  Byproducts: #{@byproducts.size}
  Ingredients: #{@ingredients.size}
SUMMARY
  end
end

class Item
  getter name, itype, slot, id
  property created_by
  property ingredient_for
  property crafts
  property basic_tool : Item | Nil
  property speed : Float64
  property energy : Float64

  def initialize(
      @name : String,
      @itype : ItemType,
      @slot : Slot | Nil,
      @id : String | Nil
    )

    @created_by = Hash(Recipe, Float64).new
    @ingredient_for = Hash(Recipe, Float64).new
    @crafts = Hash(Recipe, Nil).new
    @speed = 1.0
    @energy = 1.0
  end

  def initialize(
      @name : String,
      @itype : ItemType,
      slot : String | Nil,
      @id : String | Nil
    )

    @created_by = Hash(Recipe, Float64).new
    @ingredient_for = Hash(Recipe, Float64).new
    @crafts = Hash(Recipe, Nil).new
    @slot = slot ? Slot.parse(slot) : nil
    @speed = 1.0
    @energy = 1.0
  end

  def self.import(data : Hash(String, JSON::Any))
    hash = Hash(String, Item).new

    data.each do |i|
      name = i[0]; prop = i[1].as_h

      slot = Import.optional_string(prop,"Slot")
      id = Import.optional_string(prop,"Id")
      itype = Import.optional_string(prop, "Type")

      if itype
        hash[name] = Item.new(name, itype, slot, id)
      end
    end

    return hash
  end

  def crafts
    if basic_tool
      return @crafts.merge(basic_tool.as(Item).crafts)
    else
      return @crafts
    end
  end

  def to_s
    "#{@name}: #{@itype.to_s}#{slot ? "/"+slot.to_s : ""}"
  end

  def summary
<<-SUMMARY
#{self.to_s}
  Created By: #{created_by.size}
  Ingredient For: #{ingredient_for.size}
  Tool For: #{crafts.size}
SUMMARY
  end
end
