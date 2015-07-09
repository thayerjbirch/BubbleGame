//
//  GameScene.h
//  TBRKBubbleDemo
//

//  Copyright (c) 2014 3413. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "rngNode.h"
#import "AppDelegate.h"
#import "enemyNode.h"
#import "ParallaxBackground.h"
@class ParallaxBackground;

static const float BLOCK_SIZE = 19.0;
static const int MIN_SPAWN_DELAY = 5;
static const int INITIAL_SPAWN_DELAY = 18;
static const float ROTATION_DURATION = .25;
static const int GOLD_SPAWN_DELAY = 10;
static const CGFloat BACKGROUND_SPEED = 6;
static const AppDelegate *ourDelegate = nil;
NSMutableArray* enemyNodes;

@interface GameScene : SKScene

@property (nonatomic, retain) NSMutableArray* seededRNG;
@property (nonatomic) NSMutableArray* highScoresArray;
@property (nonatomic) NSInteger rngCounter;
@property (nonatomic) int goldSpawnTimer;
@property (nonatomic) NSInteger frameCounter;
@property (nonatomic) NSInteger spawnDelay;
@property (nonatomic) NSInteger score;
@property (nonatomic) UISwipeGestureRecognizer* swipeRightGesture;
@property (nonatomic) UISwipeGestureRecognizer* swipeLeftGesture;
@property (nonatomic) UISwipeGestureRecognizer* swipeUpGesture;
@property (nonatomic) UISwipeGestureRecognizer* swipeDownGesture;
@property (nonatomic) SKAction* action;
@property (nonatomic) NSInteger directionState;
@property (nonatomic) SKSpriteNode* player;
@property (nonatomic) NSInteger colorState;
@property (nonatomic) SKLabelNode* scoreLabel;
@property (nonatomic) BOOL gameOver;
@property (nonatomic) SKLabelNode* gameTitle;
@property (nonatomic) SKLabelNode* startButton;
@property (nonatomic) SKLabelNode* optionButton;
@property (nonatomic) SKLabelNode* scoresButton;
@property (nonatomic) SKLabelNode* exitButton;
@property (nonatomic) SKLabelNode* playTitle;
@property (nonatomic) SKLabelNode* yes;
@property (nonatomic) SKLabelNode* no;
@property (nonatomic) SKLabelNode* optionsTitleLabel;
@property (nonatomic) SKLabelNode* optionsEffectsLabel;
@property (nonatomic) SKLabelNode* optionsBackLabel;
@property (nonatomic) SKLabelNode* optionsMusicLabel;
@property (nonatomic) SKLabelNode* scoreTitleLabel;
@property (nonatomic) SKLabelNode* scoreBackLabel;
@property (nonatomic) SKLabelNode* scoreRankLabel;
@property (nonatomic) SKNode* highScoresNode;
@property (nonatomic) NSNumberFormatter* numberFormatter;
@property (nonatomic) SKAction* fadeIn;
@property (nonatomic) SKAction* fadeOut;
@property (nonatomic) ParallaxBackground* ourBackground;

-(void)addHighScore;
-(void)fadeInMenu;
@end

