#import "AppDelegate.h"
#import "GameScene.h"

@implementation AppDelegate

//
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self setupCocos2dWithOptions:@{
          CCSetupShowDebugStats: @(YES),
    }];
	
	return YES;
}

-(CCScene *)startScene
{
	// The initial scene will be GameScene
    return [GameScene scene];
}

@end
