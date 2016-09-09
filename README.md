<!doctype html>
<html lang="en">
<head>
<title>Autimistic</title>
</head>
<body>
An educational prototype for autistic people(309 project)
Since Pod is used. In order to run the app, you need to install CocoaPods.
The installation is https://cocoapods.org/
In addition, you may write pod file as:
use_frameworks!
pod 'Firebase', '>= 2.5.1'
pod 'ChameleonFramework/Swift'
target 'Autimistic' do
    pod 'Charts', '~> 2.2'
end
target 'AutimisticTests' do
end
or put every pod line into target, one way or another. Otherwise, you will have file name issue
</body>
</html>
