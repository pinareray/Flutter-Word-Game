cd ios
rm -rf Podfile.lock
pod deintegrate
pod install 
pod repo update
pod installs