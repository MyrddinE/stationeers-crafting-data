# Stationeers Crafting Automation Tool
# (c)2024 Myrddin Emrys
# Licensed under CC BY-SA

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
  getter types, items, recipes

  def initialize()
    @types = Hash(String, ItemType).new
    @items = Hash(String, Item).new
    @recipes = Hash(String, Recipe).new
  end

  def initialize(any : JSON::Any)
    @types = Hash(String, ItemType).new
    @items = Hash(String, Item).new
    @recipes = Hash(String, Recipe).new

    self.import(any)
  end

  def get_type(s)
    @types.has_key?(s) ? @types[s] : nil
  end

  def get_item(s)
    @items.has_key?(s) ? @items[s] : nil
  end

  def get_recipe(s)
    @recipes.has_key?(s) ? @recipes[s] : nil
  end

  def import(any : JSON::Any)
    h = any.as_h?
    if !h
      raise "JSON file in incorrect format."
    else
      @types = self.types(h, "ItemType")
      @items = self.items(h, "Item")
      @recipes = self.recipes(h, "Recipe")
      self.ingredients(h, "Ingredient")
      self.byproducts(h, "Byproduct")
      self.toolalternates(h, "ToolAlternate")
    end
  end

  private def types(h : Hash(String, JSON::Any), key : String)
    if !h.has_key? key
      raise "JSON file missing require key: #{key}"
    elsif !h[key].as_h?
      raise "JSON section #{key} must be a hash."
    else
      data = h[key].as_h
      hash = Hash(String, ItemType).new

      data.each do |d|
        name = d[0]; prop = d[1].as_h
        category = Import.optional_string prop,"Category"
        order = Import.uint8 prop, "Order"

        hash[name] = ItemType.new(name, category, order)
      end

      return hash
    end
  end

  private def items(h : Hash(String, JSON::Any), key : String)
    if !h.has_key? key
      raise "JSON file missing require key: #{key}"
    elsif !h[key].as_h?
      raise "JSON section #{key} must be a hash."
    else
      data = h[key].as_h
      hash = Hash(String, Item).new

      data.each do |d|
        name = d[0]; prop = d[1].as_h

        slot = Import.optional_string prop,"Slot"
        id = Import.optional_string prop,"Id"
        t = Import.optional_string prop, "Type"
        itype = get_type t

        if itype
          hash[name] = Item.new(name, itype, slot, id)
        end
      end

      return hash
    end
  end

  private def recipes(h : Hash(String, JSON::Any), key : String)
    if !h.has_key? key
      raise "JSON file missing require key: #{key}"
    elsif !h[key].as_h?
      raise "JSON section #{key} must be a hash."
    else
      data = h[key].as_h
      hash = Hash(String, Recipe).new

      data.each do |d|
        name = d[0]; prop = d[1].as_h

        note = Import.optional_string prop, "Note"
        t = Import.optional_string prop, "Tool"
        r = Import.optional_string prop, "Result"
        if t && r
          tool = get_item t
          result = get_item r
          if tool && result
            recipe = Recipe.new(name, tool, result, note)
            hash[name] = recipe
            tool.crafts[recipe] = nil
            result.created_by[recipe] = 1.0
          end
        end
      end

      return hash
    end
  end

  private def ingredients(h : Hash(String, JSON::Any), key : String)
    if !h.has_key? key
      raise "JSON file missing require key: #{key}"
    elsif !h[key].as_h?
      raise "JSON section #{key} must be a hash."
    else
      data = h[key].as_h
      data.each do |d|
        id = d[0]; prop = d[1].as_h
        if prop["Recipe"]? && prop["Quantity"]? && prop["Item"]?
          name = Import.string prop, "Recipe"
          recipe = get_recipe name
          quantity = Import.float64 prop, "Quantity"
          i = Import.string prop, "Item"
          item = get_item i
          if item && recipe
            recipe.ingredients[item] = quantity
            item.ingredient_for[recipe] = quantity
          else
            puts "                     Missing #{i}"
          end
        end
      end
    end
  end

  private def byproducts(h : Hash(String, JSON::Any), key : String)
    if !h.has_key? key
      raise "JSON file missing require key: #{key}"
    elsif !h[key].as_h?
      raise "JSON section #{key} must be a hash."
    else
      data = h[key].as_h
      data.each do |d|
        id = d[0]; prop = d[1].as_h
        if prop["Recipe"]? && prop["Quantity"]? && prop["Item"]?
          r = Import.string prop, "Recipe"
          recipe = get_recipe r
          i = Import.string prop, "Item"
          item = get_item i
          quantity = Import.float64 prop, "Quantity"
          if recipe && item
            recipe.byproducts[item] = quantity
            item.created_by[recipe] = quantity
          else
            puts "                     Missing #{i}"
          end
        end
      end
    end
  end

  private def toolalternates(h : Hash(String, JSON::Any), key : String)
    if !h.has_key? key
      raise "JSON file missing require key: #{key}"
    elsif !h[key].as_h?
      raise "JSON section #{key} must be a hash."
    else
      data = h[key].as_h
      data.each do |d|
        t = d[0]; prop = d[1].as_h

        if prop["Basic"]? && prop["Speed"]? && prop["Energy"]?
          tool = get_item t
          speed = Import.float64 prop, "Speed"
          energy = Import.float64 prop, "Energy"
          b = Import.string prop, "Basic"
          basic = get_item b

          if tool && basic
            tool.basic_tool = basic
            tool.speed = speed
            tool.energy = energy
          end
        end
      end
    end
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
