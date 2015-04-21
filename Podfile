source 'https://github.com/cocoapods/specs.git'

platform :osx

pod 'ddcli', :podspec => 'ddcli.podspec.json'
pod 'MiscMerge', :podspec => 'MiscMerge.podspec.json'
pod 'RegexKitLite', :podspec => 'RegexKitLite.podspec.json'

post_install do |installer|
    ['ddcli', 'MiscMerge'].each do |patch|
        %x(patch -p1 < patches/#{patch}.patch)
    end
end
