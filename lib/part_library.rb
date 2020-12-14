module PartLibrary
  class KspPart
    def self.interpret(file)
      valid_keys = [:name, :cost, :mass]
      props = {}
      body = file.tempfile.read
      eidx = body.lines.find_index { |e| e =~ /MODULE/ }
      part_lines = body.lines[0..eidx]
      part_lines.each do |e|
        # puts "in: #{e}"
        next if e =~ /\/\//
        results = /\s*(.+) = (.+)$/.match(e)
        next if results.nil?
        if valid_keys.include?(results[1].to_sym)
          # puts "found: '#{results[1]}' = '#{results[2]}'"
          props[results[1]] = results[2].strip
        end
      end
      return props
    end
  end
end