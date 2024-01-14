# Stationeers Crafting Automation Tool
# (c)2024 Myrddin Emrys
# Licensed under CC BY-SA

require "json"

module Import
    def self.optional_string(data : Hash(String, JSON::Any), name : String)
      if data[name]?
        data[name].as_s?
      else
        nil
      end
    end

    def self.optional_float(data : Hash(String, JSON::Any), name : String)
      if data[name]?
        data[name].as_f?
      else
        nil
      end
    end

    def self.optional_int(data : Hash(String, JSON::Any), name : String)
      if data[name]?
        data[name].as_i?
      else
        nil
      end
    end

    def self.string(data : Hash(String, JSON::Any), name : String)
      data[name].as_s
    end
    def self.float64(data : Hash(String, JSON::Any), name : String)
      data[name].as_f
    end
    def self.float32(data : Hash(String, JSON::Any), name : String)
      data[name].as_f32
    end
    def self.int64(data : Hash(String, JSON::Any), name : String)
      data[name].as_i64
    end
    def self.int32(data : Hash(String, JSON::Any), name : String)
      data[name].as_i
    end
    def self.int16(data : Hash(String, JSON::Any), name : String)
      data[name].as_i.to_i16
    end
    def self.int8(data : Hash(String, JSON::Any), name : String)
      data[name].as_i.to_i8
    end
    def self.uint32(data : Hash(String, JSON::Any), name : String)
      data[name].as_i64.to_u32
    end
    def self.uint16(data : Hash(String, JSON::Any), name : String)
      data[name].as_i.to_u16
    end
    def self.uint8(data : Hash(String, JSON::Any), name : String)
      data[name].as_i.to_u8
    end
  end
