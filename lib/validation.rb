module Validation

  class Strategy
    def apply(craft)
      return true
    end
    def error_message
      return ""
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
    def initialize(options)
      @part = options[:part]
    end
    def apply(craft)
      # search craft parts for at least one matching the given name
      found_parts = craft.parts.any? { |e| e["part"] =~ /#{@part}_.+/ }
      return found_parts
    end
    def error_message
      "part must exist! (#{@part})"
    end
  end

  class PropertyCondition < Strategy
    @@operations = [:lt, :gt, :lte, :gte, :eq, :neq]
    def initialize(options, before_compare)
      @options = options
      @key = options[:key]
      @op = options[:op]
      @value = options[:value]
      @comparator = create_comparator(options[:op], options[:value], before_compare)
    end
    def create_comparator(op, value, transform)
      op = op.to_sym
      ref = transform.call(value)
      if op == :lt
        return lambda { |e| transform.call(e) < ref }
      elsif op == :gt
        return lambda { |e| transform.call(e) > ref }
      elsif op == :lte
        return lambda { |e| transform.call(e) < ref }
      elsif op == :gte
        return lambda { |e| transform.call(e) >= ref }
      elsif op == :eq
        return lambda { |e| transform.call(e) == ref }
      elsif op == :neq
        return lambda { |e| transform.call(e) != ref }
      else
        return lambda { |e| false }
      end
    end
  end

  class ModulePropertyCondition < PropertyCondition
    def initialize(options, before_compare)
      puts "initialize(#{options})"
      @options = options
      @part = options[:part]
      @mod = options[:mod]
      @key = options[:key]
      @op = options[:op]
      @value = options[:value]
      @comparator = create_comparator(options[:op], options[:value], before_compare)
    end
    def apply(craft)
      # search craft parts for one with a module matching the given name
      # and containing a property whose key/value matches the given operation
      puts "searching for part #{@part} with module #{@mod}"
      found_parts = craft.parts.filter { |e| e["part"] =~ /#{@part}_.+/ }
      puts "parts: #{found_parts.map { |e| e["part"] }.join(", ") }"
      found_modules = found_parts.map { |e| e[:modules] }.flatten.filter { |e| e["name"] =~ /#{@mod}/ }
      puts "modules: #{found_modules.map { |e| e["name"] }.join(", ") }"
      found_modules.each do |m|
        has_prop = m.keys.include?(@key)
        if has_prop
          v = m[@key]
          puts "found #{@key} => #{v}"
          outcome = @comparator.call(v)
          if outcome
            puts "true"
          else
            puts "false"
          end
        end
      end
      result = found_modules.map { |e| e[@options[:key]] }.any? @comparator
      return result
    end
    def error_message
      puts "options: #{@options}"
      "part must exist (#{@part}) with module (#{@mod}) having property (#{@key}) with value #{@op} #{@value}"
    end
  end

  class FloatModulePropertyCondition < ModulePropertyCondition
    def initialize(options)
      super(options, lambda { |e| e.to_f })
    end
  end

  class StringModulePropertyCondition < ModulePropertyCondition
    def initialize(options)
      super(options, lambda { |e| e.to_s })
    end
  end

  class IntModulePropertyCondition < ModulePropertyCondition
    def initialize(options)
      super(options, lambda { |e| e.to_i })
    end
  end

  class ResourcePropertyCondition < PropertyCondition
    def initialize(options)
      @options = options
      @part = options[:part]
      @res = options[:res]
      @key = options[:key]
      @op = options[:op]
      @value = options[:value]
      @comparator = create_comparator(options[:op], options[:value], lambda { |e| e.to_f })
    end
    def apply(craft)
      # search craft parts for one with a module matching the given name
      # and containing a property whose key/value matches the given operation
      puts "searching for part #{@options["part"]} with module #{@options[:mod]}"
      found_parts = craft.parts.filter { |e| e["part"] =~ /#{@options[:part]}_.+/ }
      puts "parts: #{found_parts.map { |e| e["part"] }.join(", ") }"
      found_resources = found_parts.map { |e| e[:resources] }.flatten.filter { |e| e["name"] =~ /#{@options[:res]}/ }
      puts "resources: #{found_resources.map { |e| e["name"] }.join(", ") }"
      result = found_resources.map { |e| e[@options[:key]].to_f }.any? @comparator
      return result
    end
    def error_message
      puts "options: #{@options}"
      "part must exist (#{@part}) with resource (#{@res}) having property (#{@key}) with value #{@op} #{@value}"
    end
  end

end
