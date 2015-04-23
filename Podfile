source 'https://github.com/cocoapods/specs.git'

platform :osx, '10.6'

pod 'ddcli', :podspec => 'Podspecs/ddcli.podspec.json'
pod 'MiscMerge', :podspec => 'Podspecs/MiscMerge.podspec.json'
pod 'RegexKitLite', :podspec => 'Podspecs/RegexKitLite.podspec.json'

post_install do |installer|
    ['ddcli', 'MiscMerge'].each do |patch|
        %x(patch -p1 < patches/#{patch}.patch)
    end
end
