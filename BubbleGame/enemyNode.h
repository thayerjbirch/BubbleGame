//
//  enemyNode.h
//  TBRKBubble
//
//  Created by 3413 on 12/4/14.
//  Copyright (c) 2014 3413. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"
@class GameScene;

static const int RIGHT_STATE = 0;
static const int LEFT_STATE  = 1;
static const int UP_STATE    = 2;
static const int DOWN_STATE  = 3;
extern const int BASIC;
extern const int JUGG;
extern const int GOLD;
static const int GREEN = 0;
static const int PURPLE = 1;
static const int pointValueConstant = 50;
static SKAction* currentAction;
static NSInteger* dirState;
static CGRect curFrame;
static GameScene* callbackScene;

@interface EnemyNode : NSObject

@property (nonatomic) NSInteger colorValue;
@property (nonatomic) SKSpriteNode* enSprite;
@property (nonatomic) NSInteger pointValue;
@property (nonatomic) BOOL respondsToSwipe;
@property (nonatomic, readonly) NSInteger* gameFrame;
@property (nonatomic) NSString* reuseIdentifier;

-(id) init:(int)type;
-(id)init:(int)type andArg:(NSNumber*)arg;
-(id)init:(int)type andArgs:(NSArray*)args;
-(void) didCollideWithPlayer:(NSInteger)playerColorState;
-(void) update;
+(void) setStaticDirection:(NSInteger*)direction;
+(void) setCallback:(GameScene*)newCallbackScene;
+(void) setAction:(SKAction*)newAction;
-(CGPoint)spawnLocation:(int)direction inRect:(CGRect)frame;
@end



//Basic
@interface basicEnemy : EnemyNode

-(id) initBasicWithColor:(int)newColor;

@end

//Jugg
@interface Jugg : EnemyNode
@property int directionIn;

-(id) initJuggWithColor:(int)newColor andDirection:(int) direction;

@end

@interface goldEnemy : EnemyNode

-(id) initGold;

@end
