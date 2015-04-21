source 'https://github.com/cocoapods/specs.git'

platform :osx

pod 'ddcli', :podspec => 'ddcli.podspec.json'
pod 'MiscMerge', :podspec => 'MiscMerge.podspec.json'
pod 'RegexKitLite', :podspec => 'RegexKitLite.podspec.json'

post_install do |installer|
    installer.pods.each do |pod|
        puts pod.root
        if (pod.name == 'ddcli')
            %x(patch -p1 < patches/ddcli.patch)
        end
    end
end
