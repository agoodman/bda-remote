module PartLibrary
  class KspPart
    def self.interpret(file)
      valid_keys = [:name, :cost, :mass, :deflectionLiftCoeff]
      props = {}
      body = file.tempfile.read
      lines = body.lines
      line_count = lines.count
      midx = lines.index { |e| e =~ /MODULE/ } || line_count
      ridx = lines.index { |e| e =~ /RESOURCE/ } || line_count
      # eidx = [midx, ridx].min
      # part_lines = lines[0..eidx]
      # part_lines.each do |e|
      lines.each do |e|
        puts "in: #{e}"
        next if e =~ /\/\//
        results = /\s*(.+) = (.+)$/.match(e)
        next if results.nil?
        if valid_keys.include?(results[1].to_sym)
          puts "found: '#{results[1]}' = '#{results[2]}'"
          props[results[1]] = results[2].strip
          valid_keys.delete(results[1].to_sym)
        end
      end
      return props
    end
  end
end