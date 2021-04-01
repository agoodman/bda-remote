module Craft
  # This module aims to encapsulate tools used to analyze or manipulate a KSP Craft file.
  class KspVessel
    def initialize
    end
    def ship
      @vessel["ship"]
    end
    def ship_size
      @vessel["size"].split(",").map { |e| e.to_f } rescue [0, 0, 0]
    end
    def ship_type
      @vessel["type"]
    end
    def parts
      @vessel[:parts] rescue []
    end
    def part_map
      @vessel[:parts].each_with_object(Hash.new(0)) { |e,h| h[e["part"].gsub(/_.+/, "")] += 1 }
    end
    def part_dict
      @part_dict
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
          "Log",
          "MechJebLocalSettings",
          "PHYSICMATERIALCOLORS",
          "CONTROLLEDAXES",
          "CONTROLLEDACTIONS",
          "XSECTION",
          "VSLCONFIG",
          "STOREDPARTS"
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
            if active_attrs[pk].nil?
              active_attrs[pk] = pv
            else
              if active_attrs[pk].kind_of?(Array)
                active_attrs[pk].push(pv)
              else
                active_attrs[pk] = [active_attrs[pk], pv]
              end
            end
            puts "#{k} parse #{pk} => #{pv}" if debug
          end
        else
          puts "#{k} ignoring #{l}" if debug
        end
        k += 1
      end
      @vessel = vessel
      @part_dict = @vessel[:parts].each_with_object(Hash.new(0)) { |e,h| h[e["part"]] = e }
      !@vessel.nil?
    end
    def self.interpret_file(file)
      # read contents into memory
      puts "filename: #{file.original_filename}"
      puts "size: #{file.size}"
      puts "body: #{file.tempfile}"
      body = file.tempfile.read
      puts "opened: #{body.size()}"
      puts "line count: #{body.lines.count}"
      # rewind the file so the uploaded doesn't start at the end
      file.tempfile.rewind
      interpret(body)
    end

    def self.interpret(craft)
      vessel = KspVessel.new
      return nil unless vessel.build_tree(craft.lines)
      return vessel
    end

    def stackiness
      depth = 0
      begin
        determine_stack_value(@vessel[:parts].first["part"], depth+1, 0)
      rescue
        0
      end
    end
    def determine_stack_value(part_name, depth, total)
      part = @part_dict[part_name]
      return 0 unless part.kind_of?(Hash)
      links = part["link"]
      result = 0
      if !links.kind_of?(Array)
        links = [links]
      end
      links.each do |link_name|
        result += determine_stack_value(link_name, depth+1, 0)
      end
      return depth * links.count + total + result
    end
    def cost
      part_names = @part_dict.keys.map { |e| e.gsub(/_.+/, "") } rescue []
      part_costs = Part.where('name IN (?)', part_names).each_with_object(Hash.new(0)) { |e,h| h[e.name] = e.cost }
      part_names.map { |e| part_costs[e] }.reduce(0, :+)
    end
    def mass
      part_names = @part_dict.keys.map { |e| e.gsub(/_.+/, "") } rescue []
      part_masses = Part.where('name IN (?)', part_names).each_with_object(Hash.new(0)) { |e,h| h[e.name] = e.mass }
      part_names.map { |e| part_masses[e] }.reduce(0, :+)
    end
  end

  def is_craft_file_valid?(file, strategies=[])
    # open the file, search through it, and identify all parts/modules
    craft = KspVessel.interpret_file(file)
    return apply_strategies?(craft, strategies)
  end

  def is_craft_valid?(body, strategies=[])
    craft = KspVessel.interpret(body)
    return apply_strategies?(craft, strategies)
  end

  def apply_strategies?(craft, strategies=[])
    return false if craft.nil?
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

  def modify_craft(craft, keys=[], values=[])
    # find/replace the matching lines from the baseline craft file
    new_craft_lines = craft.lines.map do |line|
      keys.each.with_index do |paramKey,k|
        pattern = /^(.*#{paramKey} = )(.+)$/
        match = line.match(pattern)
        if !match.nil?
          return "#{match[1]}#{values[k].to_s}\n"
        end
      end
      line
    end
    new_craft = new_craft_lines.join
    new_craft
  end

  def upload_craft(craft, name, player_id)
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    bucket = s3.bucket(ENV['S3_BUCKET'])
    return nil if bucket.nil?

    filename = "players/#{player_id}/#{name}"
    s3obj = bucket.object(filename)
    s3obj.put(
        body: craft,
        acl: "public-read"
    )

    puts "uploaded #{craft.length} bytes to #{craft_url}"
    craft_url = s3obj.public_url
    vessel = Vessel.create(player_id: player_id, craft_url: craft_url, name: name)
    vessel
  end

end
