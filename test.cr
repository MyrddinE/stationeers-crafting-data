require "pretty_print"

enum Slot : UInt8
  A
  B
  C
end

enum ItemType: UInt8
  D
  E
  F
end

class Item
  getter name, itype, slot, id

  def initialize(
      @name : String,
      @itype : ItemType,
      @slot : Slot | Nil,
      @id : String | Nil
    )

  end

  def initialize(
      @name : String,
      @itype : ItemType,
      slot : String | Nil,
      @id : String | Nil
    )

    @slot = slot ? Slot.parse(slot) : nil
  end

  def self.import(slot : String | Nil)
    hash = Hash(String, Item).new

    (0..9).each do |i|
      name = i.to_s

      id = "something"
      itype = ItemType.parse("E")

      if itype
        hash[name] = Item.new(name, itype, slot, id)
      end
    end

    return hash
  end
end

p Item.import("A")