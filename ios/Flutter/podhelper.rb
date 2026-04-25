def flutter_root
  # 取得當前檔案 (podhelper.rb) 所在的絕對路徑，就是 ios/Flutter
  current_dir = File.dirname(File.realpath(__FILE__))
  
  # 直接在同一個資料夾找 Generated.xcconfig
  # 不再使用 '..' 或 'Flutter' 關鍵字，避免路徑疊加
  generated_xcode_build_settings_path = File.join(current_dir, 'Generated.xcconfig')
  
  unless File.exist?(generated_xcode_build_settings_path)
    raise "找不到設定檔：#{generated_xcode_build_settings_path}\n請確保已執行 flutter pub get"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/\s*FLUTTER_ROOT\s*=\s*(.*)/)
    return matches[1].strip if matches
  end
  raise "在 Generated.xcconfig 中找不到 FLUTTER_ROOT"
end

# 載入 Flutter SDK 內真正的 podhelper
require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

def flutter_ios_podfile_setup
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end