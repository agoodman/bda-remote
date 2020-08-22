module Craft
  # This module aims to encapsulate tools used to analyze or manipulate a KSP Craft file.

  def override_vessel_name(body, vessel_name)
    # override the vessel name inside the file
    # ship name is the first line in the craft file, matching "ship = <ship-name>\n"
    body.gsub(/ship = (.*)\n/, "ship = #{vessel_name}\n")
  end
end
