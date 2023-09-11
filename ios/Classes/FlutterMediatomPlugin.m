#import "FlutterMediatomPlugin.h"
#if __has_include(<flutter_mediatom/flutter_mediatom-Swift.h>)
#import <flutter_mediatom/flutter_mediatom-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_mediatom-Swift.h"
#endif

@implementation FlutterMediatomPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMediatomPlugin registerWithRegistrar:registrar];
}
@end
