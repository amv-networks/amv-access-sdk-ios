Pod::Spec.new do |s|
  s.name             = 'AMVKit'
  s.version          = '0.5.0'
  s.summary          = 'AMV Access SDK for iOS'
  s.description      = <<-DESC
The pod has functionality for downloading, storing and using a Device Certificate.
The same is done for Access Certificates with the additional functionality to delete them.

Furthermore, the kit enables easy bluetooth broadcasting and connection with access certificates.
Lastly, it has 2 easy to use methods for vehicle doors – lock and unlock.
                       DESC
 
  s.homepage         = 'https://github.com/amv-networks/amv-access-sdk-ios'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Thomas Jetzinger' => 'thomas.jetzinger@amv-networks.com' }
  s.source           = { :git => 'https://github.com/amv-networks/amv-access-sdk-ios.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '10.0'
  s.source_files =  "AMVKit/**/*"
  s.exclude_files = "**/*/Info.plist"
  s.vendored_frameworks = "Frameworks/*"
  s.swift_version = '4.2' 
end
