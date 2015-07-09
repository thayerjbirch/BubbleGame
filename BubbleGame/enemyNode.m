//
//  enemyNode.m
//  TBRKBubble
//
//  Created by 3413 on 12/4/14.
//  Copyright (c) 2014 3413. All rights reserved.
//

#import "enemyNode.h"

const int BASIC = 0;
const int JUGG = 1;
const int GOLD = 2;

@implementation EnemyNode

-(id) init:(int)type{
    self = [self init:type andArg:nil];
    return self;
}

-(id)init:(int)type andArg:(NSNumber*)arg{
    NSMutableArray *argArray = [[NSMutableArray alloc] init];
    if(arg)
        [argArray insertObject:arg atIndex:0];
    self = [self init:type andArgs:argArray];
    return self;
}

-(id)init:(int)type andArgs:(NSArray*)args{
    int newColor = rand()%2;
    switch(type){
        case JUGG:
            if(args){
                self = [[Jugg alloc] initJuggWithColor:newColor andDirection:[(NSNumber*)[args objectAtIndex:0] intValue]];
            }
            else
                NSLog(@"Action skipped:Jugg spawn attempeted without arguements.");
            break;
        case GOLD:
            self = [[goldEnemy alloc] initGold];
            break;
        default:
            self = [[basicEnemy alloc] initBasicWithColor:newColor];
            break;
    }
    do{
        self.enSprite.position = [self spawnLocation:(int)*dirState inRect:curFrame];
    }while(!self.positionAvailable);
    
    self.enSprite.zPosition = 10;
    
    return self;
}

+(void) setStaticDirection:(NSInteger*)direction{
    dirState = direction;
}

+(void) setAction:(SKAction*)newAction{
    currentAction = newAction;
}

+(void) setCallback:(GameScene*)newCallbackScene{
    callbackScene = newCallbackScene;
    curFrame = callbackScene.frame;
}

-(void) didCollideWithPlayer:(NSInteger)playerColorState{
    if([self colorValue] == playerColorState){
        callbackScene.score+=[self pointValue];
        [[self enSprite] removeFromParent];
        callbackScene.scoreLabel.text = [NSString stringWithFormat:@"%08ld",(long)callbackScene.score];
    }
    else{
        [callbackScene.player removeFromParent];
        callbackScene.gameOver = true;
        
        [callbackScene addHighScore];
        [callbackScene fadeInMenu];
    }
    return;
}

-(void) update{
    [_enSprite runAction:currentAction];
}

-(bool) positionAvailable{
    for(int i = 0; i < enemyNodes.count; i++){
        if([_enSprite intersectsNode:[[enemyNodes objectAtIndex:i] enSprite]]){
            return false;
        }
    }
    return true;
}

-(CGPoint)spawnLocation:(int)direction inRect:(CGRect)frame{
    CGPoint location;
    switch(direction){
        case RIGHT_STATE:
            location = CGPointMake(CGRectGetMinX(frame),rand()%((int)CGRectGetMaxY(frame)));
            break;
        case LEFT_STATE:
            location = CGPointMake(CGRectGetMaxX(frame), rand()%((int)CGRectGetMaxY(frame)));
            break;
        case UP_STATE:
            location = CGPointMake(rand()%((int)CGRectGetMaxX(frame)),CGRectGetMinY(frame));
            break;
        case DOWN_STATE:
            location = CGPointMake(rand()%((int)CGRectGetMaxX(frame)),CGRectGetMaxY(frame));
            break;
    }
    return location;
}

@end

//Basic Enemy
@implementation basicEnemy : EnemyNode

-(id) initBasicWithColor:(int)newColor{
    self = [super init];
    super.colorValue = newColor;
    super.respondsToSwipe = true;
    if(super.colorValue == GREEN)
        super.enSprite = [SKSpriteNode spriteNodeWithImageNamed:@"green"];
    else
        super.enSprite = [SKSpriteNode spriteNodeWithImageNamed:@"purple"];
    super.enSprite.size = CGSizeMake(BLOCK_SIZE, BLOCK_SIZE);
    super.pointValue = pointValueConstant;
    super.enSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:super.enSprite.frame.size];
    super.enSprite.zPosition = 1;
    self.reuseIdentifier = @"basic";
    return self;
}

@end


//Extra Enemy Types
//This enemy always moves the same direction, regardless of input
@implementation Jugg : EnemyNode

-(id) initJuggWithColor:(int)newColor andDirection:(int) direction{
    self = [super init];
    super.colorValue = newColor;
    super.respondsToSwipe = false;
    if(super.colorValue == GREEN)
        super.enSprite = [SKSpriteNode spriteNodeWithImageNamed:@"gJugg"];
    else
        super.enSprite = [SKSpriteNode spriteNodeWithImageNamed:@"pJugg"];
    super.enSprite.size = CGSizeMake(2 * BLOCK_SIZE, 2 * BLOCK_SIZE);
    super.pointValue = 3 * pointValueConstant;
    self.reuseIdentifier = @"jugg";
    _directionIn = direction;
    
    switch(_directionIn){
        case RIGHT_STATE:
            [super.enSprite runAction:[SKAction rotateToAngle:M_PI/2 duration:0 shortestUnitArc:true]];
            break;
        case LEFT_STATE:
            [super.enSprite runAction:[SKAction rotateToAngle:-M_PI/2 duration:0 shortestUnitArc:true]];
            break;
        case UP_STATE:
            [super.enSprite runAction:[SKAction rotateToAngle:0 duration:0 shortestUnitArc:true]];
            break;
        case DOWN_STATE:
            [super.enSprite runAction:[SKAction rotateToAngle:M_PI duration:0 shortestUnitArc:true]];
            break;
    }
    
    return self;
}

-(bool) positionAvailable{
    return true;
}

-(CGPoint)spawnLocation:(int)direction inRect:(CGRect)frame{
    CGPoint location;
    switch(_directionIn){
        case RIGHT_STATE:
            location = CGPointMake(CGRectGetMaxX(curFrame),CGRectGetMidY(curFrame));
            break;
        case LEFT_STATE:
            location = CGPointMake(CGRectGetMinX(curFrame), CGRectGetMidY(curFrame));
            break;
        case UP_STATE:
            location = CGPointMake(CGRectGetMidX(curFrame), CGRectGetMinY(curFrame));
            break;
        case DOWN_STATE:
            location = CGPointMake(CGRectGetMidX(curFrame), CGRectGetMaxY(curFrame));
            break;
    }
    NSLog(@"%f,%f", location.x, location.y);
    return location;
}

@end

@implementation goldEnemy : EnemyNode

-(id) initGold{
    super.respondsToSwipe = true;
    super.enSprite = [SKSpriteNode spriteNodeWithImageNamed:@"gold"];
    super.enSprite.size = CGSizeMake(BLOCK_SIZE, BLOCK_SIZE);
    super.pointValue = 5 * pointValueConstant;
    super.enSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:super.enSprite.frame.size];
    super.enSprite.zPosition = 1;
    return self;
}

-(void) didCollideWithPlayer:(NSInteger)playerColorState{
    callbackScene.score+=[self pointValue];
    [[self enSprite] removeFromParent];
    callbackScene.scoreLabel.text = [NSString stringWithFormat:@"%08ld",(long)callbackScene.score];
    
    return;
}

@end