Pod::Spec.new do |s|
  s.name                  = "iGlobalBannerOwlylabs"
  s.version               = "0.0.22"
  s.summary               = "Global banner which show some apps with able to open it inside current app"
  s.homepage              = "https://github.com/OwlyLabs/GlobalBanner.git"
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { "author" => "account@owlylabs.com" }
  s.platform              = :ios, '7.0'
  s.source                = { :git => "https://github.com/OwlyLabs/GlobalBanner.git", :tag => s.version.to_s }
  s.source_files          = 'Classes/*.{h,m}'
  s.public_header_files   = 'Classes/*.{h}'
  s.framework             = ["StoreKit","Foundation"]
  s.requires_arc          = true
  s.resources = ["Resources/*.png","Resources/*.xib","Resources/*.bundle"]
  s.dependency 'iCarousel'
  s.dependency 'SRActivityIndicatorView'
  s.dependency 'SRHexColor'
end