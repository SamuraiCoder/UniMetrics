# UniMetrics
Native plugin for Unity using Swift to monitor CPU, Ram and GPU usage.

# Dependencies
- Unity 2022.3.21.f
- TextMeshPro 
- Xcode tools 

# How to build Native plugin project
Native plugin is located under `Native` folder. There is a xcodeproj that you can use but for building it's recommended to follow the command process.

- Locate folder with your favourite terminal app.
- First build `iphoneos` app
> xcodebuild archive -scheme UniMetricsSwift -archivePath "./build/UniMetricsSwift-iOS" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

- Then build `iphoneSimulator`
>  xcodebuild archive -scheme UniMetricsSwift -archivePath "./build/UniMetricsSwift-Simulator" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

- Later, build the `XCFramework`
> xcodebuild -create-xcframework -framework ./build/UniMetricsSwift-iOS.xcarchive/Products/Library/Frameworks/UniMetricsSwift.framework -framework ./build/UniMetricsSwift-Simulator.xcarchive/Products/Library/Frameworks/UniMetricsSwift.framework -output ./build/UniMetricsSwift.xcframework

This will output `UniMetricsSwift.xcframework` in the build folder

- Finally move this framework into Unity under `Assets/Plugins/iOS` folder

# How to build Unity project
Cloning directly gives access to the Unity project.

- Select iOS as target on platform. File > Build Settings > Switch platform to iOS.
> This project supports both Simulator and Device build. You can select either in Player settings under Target SDK
- Select Build Settings > Build > select folder where Xcode project will be located.
-  Since the native plugin it's an XCFramework build process will automatically place it into the XCode project. No need to manually add it. 


# Caveats

- GPU tracking info it's an obscure and hard part of the API to be retrieved. Apple does not offer a solution for it and there are many non-working things out there so I prefer to use `MetricKit` to retrieve certain data but this is not intended to be working as I expect here. Also, retriving thermals can give partial information about how the device is behaving. 

# Works:

![IMG_4344](https://github.com/SamuraiCoder/UniMetrics/assets/4901895/c126b1dc-d44b-48b4-b2cb-a35b874b9627)


