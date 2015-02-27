Pod::Spec.new do |s|
s.name = "ReactiveLocalizationManager"
s.version = "1.1.0"
s.summary = "Simple reactive localization manager which helps change language in app without restarting it."
s.homepage = "https://github.com/TimurBK/ReactiveLocalizationManager"
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.author = 'Timur Kuchkarov'
s.source = { :git => "https://github.com/TimurBK/ReactiveLocalizationManager.git", :tag => s.version.to_s }
s.ios.deployment_target = '7.0'
s.source_files = 'ReactiveLocalizationManager'
s.requires_arc = true
s.dependency 'ReactiveCocoa', '~> 2.4'
end