//
//  CollisionManager.h
//  BubbleGame
//
//  Created by ikubilou on 5/24/15.
//
//

#import <Foundation/Foundation.h>
#import "enemyNode.h"
#import <SpriteKit/SpriteKit.h>
@class EnemyNode;
@class CollisionManager;

static const int NW = 0;
static const int N  = 1;
static const int NE = 2;
static const int W  = 3;
static const int C  = 4;//center
static const int E  = 5;
static const int SW = 6;
static const int S  = 7;
static const int SE = 8;

static NSInteger* dirState;

@interface CollisionContainer : NSObject

@property CGRect bounds;
@property CollisionContainer* up;
@property CollisionContainer* right;
@property CollisionContainer* down;
@property CollisionContainer* left;
@property CollisionManager* parent;

-(void)update;
-(id)initWithRect:(CGRect)location;
-(void)addNode:(EnemyNode*)targetNode;

@end

@interface CollisionManager : NSObject

@property NSMutableArray* containers;
@property NSDictionary* reuseNodes;
@property SKAction* currentAction;

-(id)initInFrame:(CGRect)frame;
-(void)setStaticDirection:(NSInteger*)direction;
-(void)setAction:(NSInteger)direction;
-(void)update;
-(void)addNewEnemy:(EnemyNode*)newNode;

@end