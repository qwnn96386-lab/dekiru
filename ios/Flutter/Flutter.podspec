Pod::Spec.new do |s|
  s.name             = 'Flutter'
  s.version          = '1.0.0'
  s.summary          = 'A concrete class for Flutter.'
  s.homepage         = 'https://flutter.dev'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Flutter Dev' => 'flutter-dev@googlegroups.com' }
  s.source           = { :git => 'https://github.com/flutter/engine', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'Flutter.framework'
end