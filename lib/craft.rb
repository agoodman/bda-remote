module Craft
  # This module aims to encapsulate tools used to analyze or manipulate a KSP Craft file.
  class KspVessel
    def initialize
    end
    def ship
      @vessel["ship"]
    end
    def parts
      @vessel[:parts]
    end
    def modules
      @vessel[:parts].map(:modules).flatten
    end
    def build_tree(lines)
      debug = false
      skippable = [
          "EVENTS",
          "ACTIONS",
          "PARTDATA",
          "AXISGROUPS",
          "UPGRADESAPPLIED",
          "MESH",
          "Log"
      ]
      vessel = { parts: [] }
      filtered_lines = lines.map { |line| line.gsub(/\t/, "").gsub(/\n/, "").gsub(/\r/, "") }
      k = 0
      depth = 0
      active_part = nil
      skipping = false
      active_event = nil
      active_actions = nil
      active_partdata = nil
      active_upgrades = nil
      active_axisgroups = nil
      active_module = nil
      active_resource = nil
      active_attrs = vessel
      attr_stack = []
      while k < filtered_lines.count
        l = filtered_lines[k]
        if skipping && l == "{"
          depth += 1
          puts "#{k} depth=#{depth}" if debug
        elsif skipping && l == "}"
          depth -= 1
          puts "#{k} depth=#{depth}" if debug
          if depth==0
            skipping = false
          end
        elsif skipping
          puts "#{k} skip #{l}" if debug
        elsif !skipping && skippable.include?(l)
          skipping = true
          puts "#{k} start skipping #{l}" if debug
        elsif active_part.nil? && l == "PART"
          attr_stack.push(active_attrs)
          active_part = {
              events: [],
              actions: [],
              partdata: [],
              upgrades: [],
              axis_groups: [],
              modules: [],
              resources: []
          }
          vessel[:parts].push(active_part)
          active_attrs = active_part
          puts "#{k} init part" if debug
        elsif active_module.nil? && l == "MODULE"
          attr_stack.push(active_attrs)
          active_module = {}
          active_attrs = active_module
          active_part[:modules].push(active_attrs)
          puts "#{k} init module" if debug
        elsif active_resource.nil? && l == "RESOURCE"
          attr_stack.push(active_attrs)
          active_resource = {}
          active_attrs = active_resource
          active_part[:resources].push(active_attrs)
          puts "#{k} init resource" if debug
        elsif !active_module.nil? && l == "{"
          puts "#{k} starting module" if debug
        elsif !active_resource.nil? && l == "{"
          puts "#{k} starting resource" if debug
        elsif !active_part.nil? && l == "{"
          puts "#{k} starting part" if debug
        elsif !active_module.nil? && l == "}"
          active_attrs = attr_stack.pop rescue nil
          active_module = nil
          puts "#{k} ending module" if debug
        elsif !active_resource.nil? && l == "}"
          active_attrs = attr_stack.pop rescue nil
          active_resource = nil
          puts "#{k} ending resource" if debug
        elsif !active_part.nil? && l == "}"
          active_attrs = attr_stack.pop rescue nil
          active_part = nil
          puts "#{k} ending part" if debug
        elsif !active_actions.nil? || !active_partdata.nil? || !active_upgrades.nil? || !active_axisgroups.nil?
          puts "#{k} ignore #{l}"
        elsif !active_attrs.nil?
          matched = l.match /(?<key>.+) = (?<val>.*)/
          if matched.nil?
            puts "#{k} skip #{l}" if debug
          else
            pk = matched[:key]
            pv = matched[:val]
            active_attrs[pk] = pv
            puts "#{k} parse #{pk} => #{pv}" if debug
          end
        else
          puts "#{k} ignoring #{l}" if debug
        end
        k += 1
      end
      @vessel = vessel
    end
    def self.interpret(file)
      # read contents into memory
      # puts "filename: #{file.original_filename}"
      # puts "size: #{file.size}"
      # puts "body: #{file.tempfile}"
      body = file.tempfile.read
      # puts "opened: #{body.size()}"
      # puts "line count: #{body.lines.count}"
      # rewind the file so the uploaded doesn't start at the end
      file.tempfile.rewind

      vessel = KspVessel.new
      vessel.build_tree(body.lines)
      return vessel
    end
  end

  def is_craft_file_valid?(file, strategies=[])
    # open the file, search through it, and identify all parts/modules
    craft = KspVessel.interpret(file)
    return false if craft.parts.count > 100
    result = true
    errors = []
    strategies.each do |s|
      if !s.apply(craft)
        errors.push(s.error_message)
        result = false
      end
    end
    flash[:error] = errors unless errors.empty?
    return result
  end

end
