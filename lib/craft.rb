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
    def build_tree_new(lines)
      debug = true
      valid_keys = [
          "PART",
          "MODULE",
          "EVENTS",
          "ACTIONS",
          "PARTDATA",
          "AXISGROUPS",
          "UPGRADESAPPLIED",
          "ToggleSameVesselInteraction",
          "SetSameVesselInteraction",
          "RemoveSameVesselInteraction"
      ]
      filtered_lines = lines.map { |line| line.gsub(/\t/, "").gsub(/\n/, "").gsub(/\r/, "") }
      key_path = ["VESSEL"]
      attrs = []
      k = 0
      while k < filtered_lines.count
        l = filtered_lines[k]
        if valid_keys.include?(l)
          key_path.push(l)
        elsif l == "{"
          # no op
        elsif l == "}"
          key_path = key_path.pop
        else
          matched = l.match /(?<key>.+) = (?<val>.*)/
          if matched.nil?
            puts "#{k} skip #{l}" if debug
          else
            pk = matched[:key]
            pv = matched[:val]
            entry = "#{key_path.join("/")}[#{pk}]=#{pv}"
            puts "#{k} entry: #{entry}"
            attrs.push(entry)
          end
        end

        k += 1
      end
    end
    def build_tree(lines)
      debug = false
      skippable = [
          "EVENTS",
          "ACTIONS",
          "PARTDATA",
          "AXISGROUPS",
          "UPGRADESAPPLIED",
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
        # elsif active_event.nil? && l == "EVENTS"
        #   active_event = {}
        #   active_attrs = active_event
        #   active_part[:events].push(active_attrs)
        #   puts "#{k} init event" if debug
        # elsif active_actions.nil? && l == "ACTIONS"
        #   active_actions = {}
        #   active_attrs = active_actions
        #   active_part[:actions].push(active_attrs)
        #   puts "#{k} init actions" if debug
        # elsif active_partdata.nil? && l == "PARTDATA"
        #   active_partdata = {}
        #   active_attrs = active_partdata
        #   active_part[:partdata].push(active_attrs)
        #   puts "#{k} init partdata" if debug
        # elsif active_upgrades.nil? && l == "UPGRADESAPPLIED"
        #   active_upgrades = {}
        #   active_attrs = active_upgrades
        #   active_part[:upgrades].push(active_attrs)
        #   puts "#{k} init upgrades" if debug
        # elsif active_axisgroups.nil? && l == "AXISGROUPS"
        #   active_axisgroups = {}
        #   active_attrs = active_axisgroups
        #   active_part[:axis_groups].push(active_attrs)
        #   puts "#{k} init axisgroups" if debug
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
        # elsif !active_event.nil? && l == "{"
        #   puts "#{k} starting event" if debug
        # elsif !active_actions.nil? && l == "{"
        #   if depth==0
        #     puts "#{k} starting actions" if debug
        #   else
        #     puts "#{k} nesting #{depth+1}"
        #   end
        #   depth += 1
        # elsif !active_partdata.nil? && l == "{"
        #   puts "#{k} starting partdata" if debug
        # elsif !active_upgrades.nil? && l == "{"
        #   puts "#{k} starting upgrades" if debug
        # elsif !active_axisgroups.nil? && l == "{"
        #   puts "#{k} starting axisgroups" if debug
        elsif !active_module.nil? && l == "{"
          puts "#{k} starting module" if debug
        elsif !active_resource.nil? && l == "{"
          puts "#{k} starting resource" if debug
        elsif !active_part.nil? && l == "{"
          puts "#{k} starting part" if debug
        # elsif !active_event.nil? && l == "}"
        #   active_attrs = nil
        #   active_event = nil
        #   puts "#{k} ending event" if debug
        # elsif !active_actions.nil? && l == "}"
        #   depth -= 1
        #   if depth==0
        #     active_attrs = nil
        #     active_actions = nil
        #     puts "#{k} ending actions" if debug
        #   else
        #     puts "#{k} un-nest #{depth}"
        #   end
        # elsif !active_partdata.nil? && l == "}"
        #   active_attrs = nil
        #   active_partdata = nil
        #   puts "#{k} ending partdata" if debug
        # elsif !active_upgrades.nil? && l == "}"
        #   active_attrs = nil
        #   active_upgrades = nil
        #   puts "#{k} ending upgrades" if debug
        # elsif !active_axisgroups.nil? && l == "}"
        #   active_attrs = nil
        #   active_axisgroups = nil
        #   puts "#{k} ending axisgroups" if debug
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

      # line = body.lines.first
      # ship = /ship = (.+)/.match(line)[1]
      # parts = body.lines.map { |e| /.*part = (.+)(_.+)/.match(e)[1] rescue nil }.compact
      # part_counts = {}
      # parts.each { |p| part_counts[p] = (part_counts[p] + 1 rescue 1) }
      # modules = body.lines.map { |e| /.*name = (.+)/.match(e)[1] rescue nil }.compact
      vessel = KspVessel.new
      vessel.build_tree(body.lines) #[0..500])
      return vessel
    end
  end

  def is_craft_file_valid?(file)
    # open the file, search through it, and identify all parts/modules
    craft = KspVessel.interpret(file)
    return false if craft.parts.count > 100
    return true
  end

end
