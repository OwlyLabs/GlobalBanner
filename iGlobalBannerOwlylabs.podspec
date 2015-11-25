Pod::Spec.new do |s|
  s.name                  = "iGlobalBannerOwlylabs"
  s.version               = "0.0.6"
  s.summary               = "Example of creating own pod. dfbsd hfg hfgj fgj"
  s.homepage              = "https://github.com/OwlyLabs/GlobalBanner.git"
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { "dfh " => "account@owlylabs.com" }
  s.platform              = :ios, '7.0'
  s.source                = { :git => "https://github.com/OwlyLabs/GlobalBanner.git", :tag => s.version.to_s }
  s.source_files          = 'Classes/*.{h,m,mm}'
  s.public_header_files   = 'Classes/*.{h,mm}'
  s.framework             = ["StoreKit","Foundation"]
  s.requires_arc          = true
  s.resources = ["Resources/*.png"]
  s.dependency 'iCarousel'

  s.xcconfig = {
       'WARNING_CFLAGS' => '-Wno-shorten-64-to-32 -Wno-logical-op-parentheses'
  }
end