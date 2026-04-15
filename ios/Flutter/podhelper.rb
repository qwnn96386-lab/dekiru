# 這是 Flutter 官方標準的 podhelper.rb 範本
def flutter_install_all_ios_pods(ios_application_path = nil)
  flutter_application_path = ios_application_path || File.join('..', '..')
  app_config = JSON.parse(File.read(File.join(flutter_application_path, '.metadata')))
  
  # 遍歷所有 Flutter 插件並加入 Podfile
  app_config['plugins']['ios'].each do |plugin|
    pod plugin['name'], :path => File.join(flutter_application_path, '.symlinks', 'plugins', plugin['name'], 'ios')
  end
end

def flutter_additional_ios_build_settings(target)
  return if target.platform_name != :ios
  
  target.build_configurations.each do |config|
    # 確保基本編譯設定存在
    config.build_settings['ENABLE_BITCODE'] = 'NO'
    config.build_settings['APP_FRAMEWORK_HIGHLIGHT_FILENAME'] = '$(inherited)'
  end
end