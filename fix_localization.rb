#!/usr/bin/env ruby
require 'xcodeproj'

project_path = '/Users/chaedongjoo/Developer/AIhealth/AIhealth.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.first

# Find or create Resources group
resources_group = project.main_group.find_subpath('AIhealth/Resources', true)

# Add localization files
['ko', 'en', 'ja'].each do |lang|
  lproj_path = "AIhealth/Resources/#{lang}.lproj"
  strings_path = "#{lproj_path}/Localizable.strings"

  # Create language group if it doesn't exist
  lang_group = resources_group.find_subpath("#{lang}.lproj", true)

  # Add Localizable.strings file
  file_ref = lang_group.new_reference(strings_path)
  file_ref.last_known_file_type = 'text.plist.strings'

  # Add to build phase
  target.resources_build_phase.add_file_reference(file_ref)

  puts "Added #{lang} localization"
end

# Save project
project.save

puts "✅ Localization files added to Xcode project!"
puts "Please open Xcode and verify the files are visible."
