#import "GameScene.h"

// The constant yeti speed
#define yetiSpeed 360.0;

#pragma mark - GameScene

@implementation GameScene
{
    // Declaring a private CCSprite instance
    CCSprite *_yeti;
    
    // Available screen limits
    float _topLimit;
    float _bottomLimit;
    
    // Declare snowballs array
    NSMutableArray *_snowBalls;
    
    // Declare number of snowballs
    int _numSnowBalls;
    
    // Label to show the score
    CCLabelTTF *_scoreLabel;
    
    // Score count
    int _gameScore;
    
    // Collisions flag
    BOOL _collisionDetected;
    
    // Score target
    int _gameOverScore;
}

#pragma mark - Create & Destroy

+(GameScene *) scene {
    return [[self alloc] init];
}

#pragma mark - Initalizing and configuring the game

-(id) init {
	self = [super init];
    if (!self) return(nil);
    
    // Creating the yeti sprite using an image file and adding it to the scene
    _yeti = [CCSprite spriteWithImageNamed:@"yeti.png"];
   [self addChild:_yeti];

    // Positioning the yeti in the desired place
    CGSize screenSize = [CCDirector sharedDirector].viewSize;
    _yeti.position = CGPointMake(screenSize.width * 3 / 4, screenSize.height / 2);
    
    // Adding the background image
    CCSprite *background = [CCSprite spriteWithImageNamed:@"background.png"];
    background.position = CGPointMake(screenSize.width / 2, screenSize.height / 2);
    [self addChild:background z:-1];
    
    // Enabling user interaction
    self.userInteractionEnabled = TRUE;
    
    // Initializing playable limits
    _topLimit = screenSize.height - 3 * _yeti.texture.contentSize.height/2;
    _bottomLimit = _yeti.texture.contentSize.height;
    
    // Creating a temporal sprite to get its height
    CCSprite *tempSnowBall = [CCSprite spriteWithImageNamed:@"snowball0.png"];
    float snowBallHeight = tempSnowBall.texture.contentSize.height;
    
    // Calculate number of snowballs that fits in the screen
    _numSnowBalls = (screenSize.height - 3 * _yeti.texture.contentSize.height/2) / snowBallHeight;
    
    // Initialize array with capacity
    _snowBalls = [NSMutableArray arrayWithCapacity:_numSnowBalls];
    
    for (int i = 0; i < _numSnowBalls;i++) {
        CCSprite *snowBall = [CCSprite spriteWithImageNamed:[NSString stringWithFormat:@"snowball%i.png", i % 3]];
        
        // Add the snow ball to the scene
       [self addChild:snowBall];
        
        // Add the snow ball to the array
        [_snowBalls addObject:snowBall];
    }
    
    // Initialize the score target
    _gameOverScore = 150;
    
    [self initSnowBalls];
    
    // Initialize score count
    _gameScore = 0;
    
    // Initialize score label
    _scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"SCORE: %i", _gameScore] fontName:@"Chalkduster" fontSize:15];
    _scoreLabel.color = [CCColor orangeColor];
    _scoreLabel.position = CGPointMake(screenSize.width, screenSize.height);
    
    // Right-alligning the label
    _scoreLabel.anchorPoint = CGPointMake(1.0, 1.0);
    
    [self addChild:_scoreLabel];
    
    // Initialize the collision flag to false
    _collisionDetected = FALSE;
    
    // Playing background music
    [[OALSimpleAudio sharedInstance] playBg:@"background_music.mp3" loop:YES];[[OALSimpleAudio sharedInstance] playBg:@"background_music.mp3" loop:YES];
    
	return self;
}

#pragma mark - Handling touches

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Controlling actions
    [_yeti stopActionByTag:0];
    
    // Moving the yeti to the touched position
    CGPoint touchLocation = [touch locationInNode:self];
    [self moveYetiToPosition:touchLocation];
}

#pragma mark - Moving the yeti

-(void) moveYetiToPosition:(CGPoint)nextPosition{

    if (nextPosition.y > _topLimit) {
        nextPosition.y = _topLimit;
    } else if (nextPosition.y < _bottomLimit) {
        nextPosition.y = _bottomLimit;
    }
    
	// We don't want to worry about the x coordinates
    nextPosition.x = _yeti.position.x;
    
    // We want the yeti to move on a constant speed
    float duration = ccpDistance(nextPosition, _yeti.position) / yetiSpeed;

    // Move the yeti to the touched position
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:duration position:CGPointMake(_yeti.position.x, nextPosition.y)];
    
    // Controlling actions
    [actionMove setTag:0];
	[_yeti runAction:actionMove];
}

#pragma mark - Initializing the snow balls

-(void) initSnowBalls {
    
    CCSprite *tempSnowBall = [_snowBalls objectAtIndex:0];
    
    // Position y for the first snowball
    int positionY = _bottomLimit;
    
    // Calculate the gaps between snowballs to be positioned proportionally
    CGSize screenSize = [CCDirector sharedDirector].viewSize;
    float blankScreenSize = (screenSize.height - 3 * _yeti.texture.contentSize.height/2) - _numSnowBalls * tempSnowBall.contentSize.height;
    float gap = blankScreenSize / (_numSnowBalls - 1);
    
    for (int i = 0; i < _snowBalls.count; i++){
        
        CCSprite *snowBall = [_snowBalls objectAtIndex:i];
        
        // Put the snow ball out of the screen
        CGPoint snowBallPosition = CGPointMake(-snowBall.texture.contentSize.width / 2, positionY);
        positionY += snowBall.contentSize.height + gap;
        snowBall.position = snowBallPosition;
        
        [snowBall stopAllActions];
    }
    
    [self schedule:@selector(throwSnowBall:) interval:1.5f];
}

#pragma mark - Throwing snowballs

-(void) throwSnowBall:(CCTime) delta {
    for (int i = 0; i < _numSnowBalls; i++){
        
        // Get a random number between 0 and the size of the array
        int randomSnowBall = arc4random_uniform(_numSnowBalls);
        
        // Select the snowball at the random index
        CCSprite *snowBall = [_snowBalls objectAtIndex:randomSnowBall];
        
        // Don't want to stop the snow ball if it's already moving
        if ([snowBall numberOfRunningActions] == 0) {
            
            // Specify the final position of the snowball
            CGPoint nextSnowBallPosition = snowBall.position;
            nextSnowBallPosition.x = [CCDirector sharedDirector].viewSize.width + snowBall.texture.contentSize.width / 2;
            
            // Move the snowball to its next position out of the screen
            CCActionMoveTo *throwSnowBallAction = [CCActionMoveTo actionWithDuration:1 position:nextSnowBallPosition];
            
            // Reset the position of the snowball to reuse it
            CCActionCallBlock *callDidThrown = [CCActionCallBlock actionWithBlock:^{
                
                CGPoint position = snowBall.position;
                position.x = -snowBall.texture.contentSize.width / 2;
                snowBall.position = position;
                
                // Evaluating if a collision happened
                if (!_collisionDetected){
                    [self increaseScore];
                }
                
                // Recovering the visibility of the snowball
                [snowBall setVisible:TRUE];
            }];
            
            // Playing sound effects
            [[OALSimpleAudio sharedInstance] playEffect:@"avalanche.mp3"];
            
            // Execute the movement and the reset in a sequence
            CCActionSequence *sequence = [CCActionSequence actionWithArray:@[throwSnowBallAction, callDidThrown]];
            [snowBall runAction:sequence];
            
            _collisionDetected = FALSE;
            
            // To avoid moving more than one snowball at the same time
            break;
        }
    }
}

#pragma mark - Scheduling update

-(void) update:(CCTime)delta {
    for (CCSprite *snowBall in _snowBalls){
        // Detect collision
        if (CGRectIntersectsRect(snowBall.boundingBox, _yeti.boundingBox) && !_collisionDetected) {
            [snowBall setVisible:FALSE];
            
            // Managing collisions
            [self manageCollision];
        }
    }
}

#pragma mark - Managing collisions

-(void) manageCollision {
    
    // Playing sound effects
    [[OALSimpleAudio sharedInstance] playEffect:@"growl.m4a"];
    
    _collisionDetected = TRUE;
    
    _yeti.color = [CCColor redColor];
    CCAction *actionBlink = [CCActionBlink actionWithDuration:0.9 blinks:3];
    CCActionCallBlock *callDidBlink = [CCActionCallBlock actionWithBlock:^{
        // Recover the visibility of the snowball and its tint
        [_yeti setVisible:TRUE];
        _yeti.color = [CCColor whiteColor];
    }];
    
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[actionBlink, callDidBlink]];
    [_yeti runAction:sequence];
    
}

#pragma mark - Increasing the score

-(void) increaseScore{
    _gameScore += 10;
    
    // If we reach the score target, the game is over
    if (_gameScore >= _gameOverScore){
        [self gameOver];
        return;
    }
    
    [_scoreLabel setString:[NSString stringWithFormat:@"SCORE: %i", _gameScore]];
}

#pragma mark - Handling game over

-(void) gameOver{
    
    CGSize screenSize = [CCDirector sharedDirector].viewSize;
    
    // Initializing and positioning the game over label
    CCLabelTTF *gameOverLabel = [CCLabelTTF labelWithString:@"LEVEL COMPLETE!" fontName:@"Chalkduster" fontSize:40];
    
    gameOverLabel.color = [CCColor greenColor];
    gameOverLabel.position = CGPointMake(screenSize.width/2, screenSize.height/2);

    [self addChild:gameOverLabel];
    
    // Removing score label
    [self removeChild:_scoreLabel];
    
    // Stop throwing snowballs
    [self unscheduleAllSelectors];
    
    // Disable touches
    self.userInteractionEnabled = FALSE;
    
    // Stop background music and sound effects
    [[OALSimpleAudio sharedInstance] stopEverything];
}

@end
