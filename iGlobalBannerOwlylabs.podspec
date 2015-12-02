Pod::Spec.new do |s|
  s.name                  = "iGlobalBannerOwlylabs"
  s.version               = "0.0.12"
  s.summary               = "Example of creating own pod. dfbsd hfg hfgj fgj"
  s.homepage              = "https://github.com/OwlyLabs/GlobalBanner.git"
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { "dfh " => "account@owlylabs.com" }
  s.platform              = :ios, '7.0'
  s.source                = { :git => "https://github.com/OwlyLabs/GlobalBanner.git", :tag => s.version.to_s }
  s.source_files          = 'Classes/*.{h,m}'
  s.public_header_files   = 'Classes/*.{h}'
  s.framework             = ["StoreKit","Foundation"]
  s.requires_arc          = true
  s.resources = ["Resources/*.png","Resources/*.xib"]
  s.dependency 'iCarousel'

end