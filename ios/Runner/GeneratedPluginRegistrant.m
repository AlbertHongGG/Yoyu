//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<home_widget/HomeWidgetPlugin.h>)
#import <home_widget/HomeWidgetPlugin.h>
#else
@import home_widget;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<workmanager_apple/WorkmanagerPlugin.h>)
#import <workmanager_apple/WorkmanagerPlugin.h>
#else
@import workmanager_apple;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [HomeWidgetPlugin registerWithRegistrar:[registry registrarForPlugin:@"HomeWidgetPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
  [WorkmanagerPlugin registerWithRegistrar:[registry registrarForPlugin:@"WorkmanagerPlugin"]];
}

@end
