#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameScene : CCScene {
    
}

+(GameScene *) scene;

-(void) moveYetiToPosition:(CGPoint)nextPosition;

-(void) initSnowBalls;

-(void) manageCollision;

-(void) increaseScore;

-(void) gameOver;

@end
