#!/usr/bin/env ruby

require 'xcodeproj'

project_path = '/Users/chaedongjoo/Developer/AIhealth/AIhealth.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first
main_group = project.main_group['AIhealth']

# Create groups if they don't exist
def ensure_group(parent, name)
  parent[name] || parent.new_group(name)
end

# Add files to project
swift_files = [
  # Models
  'Models/ChatMessage.swift',
  'Models/DiagnosisRecord.swift',
  'Models/Reservation.swift',

  # ViewModels
  'ViewModels/ChatViewModel.swift',
  'ViewModels/ReservationViewModel.swift',
  'ViewModels/ReportViewModel.swift',

  # Services
  'Services/Network/GptApiService.swift',
  'Services/Network/FirebaseManager.swift',
  'Services/Network/SystemPrompt.swift',
  'Services/Repository/ChatRepository.swift',
  'Services/Repository/ReservationRepository.swift',
  'Services/Repository/DiagnosisRepository.swift',

  # Utilities
  'Utilities/PDFGenerator.swift',
  'Utilities/NotificationManager.swift',

  # Theme
  'Theme/Colors.swift',
  'Theme/Theme.swift',

  # Views
  'Views/MainTabView.swift',
  'Views/Home/DashboardHomeScreen.swift',
  'Views/Chat/ChatScreen.swift',
  'Views/Reservation/ReservationScreen.swift',
  'Views/Report/ReportPreviewScreen.swift',
  'Views/Report/ReportListScreen.swift',
  'Views/Components/CommonButton.swift',
  'Views/Components/CommonTextField.swift',
  'Views/Components/CommonCard.swift',
  'Views/Components/LoadingView.swift'
]

base_path = '/Users/chaedongjoo/Developer/AIhealth/AIhealth'

swift_files.each do |file_path|
  full_path = File.join(base_path, file_path)

  next unless File.exist?(full_path)

  # Create group structure
  parts = file_path.split('/')
  current_group = main_group

  # Navigate/create nested groups
  parts[0..-2].each do |group_name|
    current_group = ensure_group(current_group, group_name)
  end

  # Check if file already exists in project
  file_name = parts.last
  existing_file = current_group.files.find { |f| f.path == file_name }

  unless existing_file
    # Add file reference
    file_ref = current_group.new_file(full_path)

    # Add to target
    target.add_file_references([file_ref])

    puts "Added: #{file_path}"
  else
    # Make sure it's in the target
    build_file = target.source_build_phase.files.find { |bf| bf.file_ref == existing_file }
    unless build_file
      target.add_file_references([existing_file])
      puts "Added to target: #{file_path}"
    end
  end
end

# Save project
project.save

puts "\n✅ Project configuration updated!"
puts "Now run: xcodebuild clean build"
