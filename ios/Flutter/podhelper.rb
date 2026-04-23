# This file is part of Flutter. It is used by CocoaPods to integrate Flutter into your iOS app.

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first."
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/\s*FLUTTER_ROOT\s*=\s*(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig and run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

def flutter_ios_podfile_setup
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end