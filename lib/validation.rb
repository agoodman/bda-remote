module Validation

  class Strategy
    def valid?(craft)
      return true
    end
  end

  class NotCondition < Strategy
    def initialize(strategy)
      @strategy = strategy
    end
    def apply(craft)
      return !strategy(craft)
    end
  end

  class OrCondition < Strategy
    def initialize(a, b)
      @a = a
      @b = b
    end
    def apply(craft)
      return a(craft) || b(craft)
    end
  end

  class AndCondition < Strategy
    def initialize(a, b)
      @a = a
      @b = b
    end
    def apply(craft)
      return a(craft) && b(craft)
    end
  end

  class XorCondition < Strategy
    def initialize(a, b)
      @a = a
      @b = b
    end
    def apply(craft)
      ar = a(craft)
      br = b(craft)
      return (ar && !br) || (!ar && br)
    end
  end

  class PartExists < Strategy
    def initialize(part)
      @part = part
    end
    def apply(craft)
      # search craft parts for at least one matching the given name
      found_parts = craft.parts.any? { |e| e["part"] =~ /#{@part}_.+/ }
      return found_parts
    end
  end

  class ModulePropertyCondition < Strategy
    @@operations = [:lt, :gt, :lte, :gte, :eq, :neq]
    def initialize(part, mod, key, op, value, before_compare)
      @part = part
      @mod = mod
      @key = key
      @comparator = create_comparator(op, value, before_compare)
    end
    def apply(craft)
      # search craft parts for one with a module matching the given name
      # and containing a property whose key/value matches the given operation
      found_parts = craft.parts.filter { |e| e["part"] =~ /#{@part}_.+/ }
      puts "parts: #{found_parts.map { |e| e["part"] }.join(", ") }"
      found_modules = found_parts.map { |e| e[:modules] }.flatten.filter { |e| e["name"] =~ /#{@mod}/ }
      puts "modules: #{found_modules.map { |e| e["name"] }.join(", ") }"
      result = found_modules.map { |e| e[@key].to_f }.any? @comparator
      return result
    end
    def create_comparator(op, value, transform)
      ref = transform.call(value)
      if op == :lt
        return lambda { |e| e < ref }
      elsif op == :gt
        return lambda { |e| e > ref }
      elsif op == :lte
        return lambda { |e| e <= ref }
      elsif op == :gte
        return lambda { |e| e >= ref }
      elsif op == :eq
        return lambda { |e| e == ref }
      elsif op == :neq
        return lambda { |e| e != ref }
      else
        return lambda { |e| false }
      end
    end
  end

  class FloatModulePropertyCondition < ModulePropertyCondition
    def initialize(part, mod, key, op, value)
      super(part, mod, key, op, value, lambda { |e| e.to_f })
    end
  end

  class StringModulePropertyCondition < ModulePropertyCondition
    def initialize(part, mod, key, op, value)
      super(part, mod, key, op, value, lambda { |e| e.to_s })
    end
  end

  class IntModulePropertyCondition < ModulePropertyCondition
    def initialize(part, mod, key, op, value)
      super(part, mod, key, op, value, lambda { |e| e.to_i })
    end
  end
end
