//
//  GameScene.m
//  TBRKBubbleDemo
//
//  Created by 3413 on 11/18/14.
//  Copyright (c) 2014 3413. All rights reserved.
//

#import "GameScene.h"
#import "AppDelegate.h"
#import "GameViewController.h"

@implementation GameScene


-(void)didMoveToView:(SKView *)view {
    ourDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    _gameOver = true;
    [self createMenu];
    [self createGameStartMenu];
    [self fadeinGameStartMenu];
    [self createOptionsMenu];
    [self createScoreMenu];
    [self createGestureListeners:view];
    [self setUpBackground];
    
    [EnemyNode setStaticDirection:&(_directionState)];
    [EnemyNode setCallback:self];


    _rngCounter = 0;
    _seededRNG = [NSMutableArray arrayWithCapacity:100];
    for(int i = 0; i<100; i++){
        _seededRNG[i] = [[rngNode alloc] init];
    }
    

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //NSLog(NSStringFromCGPoint(location));
    NSArray *nodesAtTouch = [self nodesAtPoint:location];
    if(!_gameOver){
        [_player removeFromParent];
        _colorState = !_colorState;
        if(_colorState == GREEN)
            _player = [SKSpriteNode spriteNodeWithImageNamed:@"gPlayer"];
        else
            _player = [SKSpriteNode spriteNodeWithImageNamed:@"pPlayer"];
        _player.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        _player.size = CGSizeMake(BLOCK_SIZE,BLOCK_SIZE);
        _player.zPosition = 10;
        
        switch(_directionState){
            case RIGHT_STATE:
                [_player runAction:[SKAction rotateToAngle:M_PI/2 duration:0 shortestUnitArc:true]];
                break;
            case LEFT_STATE:
                [_player runAction:[SKAction rotateToAngle:-M_PI/2 duration:0 shortestUnitArc:true]];
                break;
            case UP_STATE:
                [_player runAction:[SKAction rotateToAngle:M_PI duration:0 shortestUnitArc:true]];
                break;
            case DOWN_STATE:
                [_player runAction:[SKAction rotateToAngle:0 duration:0 shortestUnitArc:true]];
                break;
        }
        [self addChild:_player];
    }
    else{
        for(int i = 0; i < nodesAtTouch.count; i++){
            SKNode *node = [nodesAtTouch objectAtIndex:i];
            if ([node.name isEqualToString:@"Menu"]) {
                [_scoreLabel removeFromParent];
                [_scoreLabel runAction: _fadeOut];
                [self fadeOutMenu];
                [self fadeinGameStartMenu];
            }
            else if ([node.name isEqualToString:@"Play Again"]) {
                [self newGameValues];
                [self fadeOutMenu];
            }
            if ([node.name isEqualToString:@"Start Game"]) {
                [self setInitialValues];
                [self fadeOutGameStartMenu];
            }
            else if ([node.name isEqualToString:@"Options"]) {
                [self fadeOutGameStartMenu];
                if([ourDelegate.player isPlaying]) {
                    _optionsMusicLabel.fontColor = [UIColor whiteColor];
                }
                else {
                    _optionsMusicLabel.fontColor = [UIColor grayColor];
                }
                [self fadeInOptions];
            }
            else if ([node.name isEqualToString:@"High Scores"]) {
                [self fadeOutGameStartMenu];
                [self fadeInScores];
            }
            else if ([node.name isEqualToString:@"Exit Game"]) {
                
                exit(0);
            }
            else if ([node.name isEqualToString:@"Back"]) {
                [self fadeOutOptions];
                [self fadeinGameStartMenu];
            }
            else if ([node.name isEqualToString:@"ScoreBack"]){
                [self fadeOutScores];
                [self fadeinGameStartMenu];
            }
            
            else if ([node.name isEqualToString:@"Music"]) {
                if([ourDelegate.player isPlaying]) {
                    [ourDelegate.player stop];
                    ourDelegate.player.currentTime = 0;
                    _optionsMusicLabel.fontColor = [UIColor grayColor];
                }
                else {
                    [ourDelegate.player play];
                    _optionsMusicLabel.fontColor = [UIColor whiteColor];
                }
            }
            else if ([node.name isEqualToString:@"Sound Effects"]) {
            }
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    if(!_gameOver){
        if(_frameCounter < _spawnDelay){
            _frameCounter++;
            _goldSpawnTimer++;
        }
        else{
            [self spawnNewEnemy];
        }
        if(_rngCounter >= 99){
            _rngCounter = 0;
            [self spawnNewJugg:[NSNumber numberWithInt:rand()%4]];
            if(_spawnDelay>MIN_SPAWN_DELAY){
                _spawnDelay--;
            }
            if(_goldSpawnTimer >= GOLD_SPAWN_DELAY){
                _goldSpawnTimer = 0;
                [self spawnNewGold];
            }
        }
        else{
            _rngCounter++;
        }
        for(int i = 0; i < enemyNodes.count; i++){
            //[[enemyNodes objectAtIndex:i] update];
            if([_player intersectsNode:[[enemyNodes objectAtIndex:i] enSprite]]){
                [[enemyNodes objectAtIndex:i] didCollideWithPlayer:_colorState];
                [enemyNodes removeObjectAtIndex:i];
            }
        }
    }
    else{
        for(int i = 0; i < [enemyNodes count]; i++){
            if([[[enemyNodes objectAtIndex:i] enSprite] alpha] == 0.0){
                [[[enemyNodes objectAtIndex:i] enSprite] removeFromParent];
                [enemyNodes removeObjectAtIndex:i];
            }
        }
    }
    [_ourBackground update];
}


// all handles functions
-(void) handleSwipeRight:( UISwipeGestureRecognizer *) recognizer {
    if(!_gameOver && _directionState!= RIGHT_STATE){
        _action = [SKAction moveByX:100.0 y:0.0 duration:1.0];
        _directionState = RIGHT_STATE;
        for(int i = 0; i < [enemyNodes count]; i++){
            EnemyNode *node = [enemyNodes objectAtIndex:i];
            if(node.respondsToSwipe){
                [[node enSprite] removeActionForKey:@"move"];
                [[node enSprite] runAction:[SKAction repeatActionForever:_action] withKey:@"move"];
            }
        }
        [_player runAction:[SKAction rotateToAngle:M_PI/2 duration:ROTATION_DURATION shortestUnitArc:true]];
        [_ourBackground setXSpeed:BACKGROUND_SPEED andYSpeed:0];
    }
}

-(void) handleSwipeLeft:( UISwipeGestureRecognizer *) recognizer {
    if(!_gameOver && _directionState!= LEFT_STATE){
        _action = [SKAction moveByX:-100.0 y:0.0 duration:1.0];
        _directionState = LEFT_STATE;
        for(int i = 0; i < [enemyNodes count]; i++){
            EnemyNode *node = [enemyNodes objectAtIndex:i];
            if(node.respondsToSwipe){
                [[node enSprite] removeActionForKey:@"move"];
                [[node enSprite] runAction:[SKAction repeatActionForever:_action] withKey:@"move"];
            }
        }
        [_player runAction:[SKAction rotateToAngle:-M_PI/2 duration:ROTATION_DURATION shortestUnitArc:true]];
        [_ourBackground setXSpeed:-BACKGROUND_SPEED andYSpeed:0];
    }
}

-(void) handleSwipeUp:( UISwipeGestureRecognizer *) recognizer {
    if(!_gameOver && _directionState!= UP_STATE){
        _action = [SKAction moveByX:0.0 y:100.0 duration:1.0];
        _directionState = UP_STATE;
        for(int i = 0; i < [enemyNodes count]; i++){
            EnemyNode *node = [enemyNodes objectAtIndex:i];
            if(node.respondsToSwipe){
                [[node enSprite] removeActionForKey:@"move"];
                [[node enSprite] runAction:[SKAction repeatActionForever:_action] withKey:@"move"];
            }
        }
    }
    [_player runAction:[SKAction rotateToAngle:-M_PI duration:ROTATION_DURATION shortestUnitArc:true]];
    [_ourBackground setXSpeed:0 andYSpeed:BACKGROUND_SPEED];
}

-(void) handleSwipeDown:( UISwipeGestureRecognizer *) recognizer {
    if(!_gameOver && _directionState!= DOWN_STATE){
        _action = [SKAction moveByX:0.0 y:-100.0 duration:1.0];
        _directionState = DOWN_STATE;
        for(int i = 0; i < [enemyNodes count]; i++){
            EnemyNode *node = [enemyNodes objectAtIndex:i];
            if(node.respondsToSwipe){
                [[node enSprite] removeActionForKey:@"move"];
                [[node enSprite] runAction:[SKAction repeatActionForever:_action] withKey:@"move"];
            }
        }
        [_player runAction:[SKAction rotateToAngle:2*M_PI duration:ROTATION_DURATION shortestUnitArc:true]];
        [_ourBackground setXSpeed:0 andYSpeed:-BACKGROUND_SPEED];
    }
}

-(void) spawnNewEnemy{
    EnemyNode *newEnemy;
    _frameCounter = 0;
    newEnemy = [[EnemyNode alloc] init:BASIC];
    [[newEnemy enSprite] runAction:[SKAction repeatActionForever:_action] withKey:@"move"];
    [self addChild:[newEnemy enSprite]];
    [enemyNodes addObject:newEnemy];
}

-(void) spawnNewGold{
    EnemyNode *newEnemy;
    _frameCounter = 0;
    newEnemy = [[EnemyNode alloc] init:GOLD];
    [[newEnemy enSprite] runAction:[SKAction repeatActionForever:_action] withKey:@"move"];
    [self addChild:[newEnemy enSprite]];
    [enemyNodes addObject:newEnemy];
}

-(void) spawnNewJugg:(NSNumber*)direction{
    EnemyNode *newEnemy;
    _frameCounter = 0;
    newEnemy = [[EnemyNode alloc] init:JUGG andArg:direction];
    [[newEnemy enSprite] runAction:[SKAction repeatActionForever:_action] withKey:@"move"];
    int x = [direction intValue];
    
    switch(x){
        case RIGHT_STATE:
            [newEnemy.enSprite runAction:[SKAction repeatActionForever:[SKAction moveByX:-150.0 y:0.0 duration:1.0]] withKey:@"move"];
            break;
        case LEFT_STATE:
            [newEnemy.enSprite runAction:[SKAction repeatActionForever:[SKAction moveByX:150.0 y:0.0 duration:1.0]] withKey:@"move"];
            break;
        case UP_STATE:
            [newEnemy.enSprite runAction:[SKAction repeatActionForever:[SKAction moveByX:0.0 y:150.0 duration:1.0]] withKey:@"move"];
            break;
        case DOWN_STATE:
            [newEnemy.enSprite runAction:[SKAction repeatActionForever:[SKAction moveByX:0.0 y:-150.0 duration:1.0]] withKey:@"move"];
            break;
    }
    
    [self addChild:[newEnemy enSprite]];
    [enemyNodes addObject:newEnemy];
}

-(void)addHighScore {
    AppDelegate *ourDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSInteger counter=0;
    while (counter < [[ourDelegate highScores] count] && [NSNumber numberWithInteger:_score] < [[ourDelegate highScores] objectAtIndex:counter]) {
        counter++;
    }
    [[ourDelegate highScores] insertObject:[NSNumber numberWithInteger:_score] atIndex:counter];
    if([[ourDelegate highScores] count] > 10) {
        [[ourDelegate highScores] removeObjectAtIndex:10];
    }
    [NSKeyedArchiver archiveRootObject:ourDelegate.highScores toFile:[ourDelegate archivePath]];
    
}

-(void)createGestureListeners:(SKView *)view {
    _swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [_swipeRightGesture setDirection: UISwipeGestureRecognizerDirectionRight];
    [view addGestureRecognizer:_swipeRightGesture ];
    
    _swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [_swipeLeftGesture setDirection: UISwipeGestureRecognizerDirectionLeft];
    [view addGestureRecognizer:_swipeLeftGesture ];
    
    _swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
    [_swipeUpGesture setDirection: UISwipeGestureRecognizerDirectionUp];
    [view addGestureRecognizer:_swipeUpGesture ];
    
    _swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
    [_swipeDownGesture setDirection: UISwipeGestureRecognizerDirectionDown];
    [view addGestureRecognizer:_swipeDownGesture ];
}

-(void)newGameValues {
    _gameOver = false;
    [self addChild:_player];
    _score = 0;
    _scoreLabel.text = [NSString stringWithFormat:@"%08ld",(long)_score];
    _spawnDelay = INITIAL_SPAWN_DELAY;
    
    switch(_directionState){
        case RIGHT_STATE:
            [_player runAction:[SKAction rotateToAngle:M_PI/2 duration:0 shortestUnitArc:true]];
            break;
        case LEFT_STATE:
            [_player runAction:[SKAction rotateToAngle:-M_PI/2 duration:0 shortestUnitArc:true]];
            break;
        case UP_STATE:
            [_player runAction:[SKAction rotateToAngle:M_PI duration:0 shortestUnitArc:true]];
            break;
        case DOWN_STATE:
            [_player runAction:[SKAction rotateToAngle:0 duration:0 shortestUnitArc:true]];
            break;
    }

}

-(void)setInitialValues {
    
    enemyNodes = [[NSMutableArray alloc] init];
    _action = [SKAction moveByX:0.0 y:-100.0 duration:1.0];
    //[EnemyNode setAction:[SKAction moveByX:0.0 y:-100.0 duration:1.0]];
    _directionState = DOWN_STATE;
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    _scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) - _scoreLabel.frame.size.height);
    _scoreLabel.fontSize = 18;
    _scoreLabel.zPosition = 1.0;
    [self addChild:_scoreLabel];
    _player = [SKSpriteNode spriteNodeWithImageNamed:@"gPlayer"];
    _colorState = GREEN;
    _player.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    _player.size = CGSizeMake(BLOCK_SIZE,BLOCK_SIZE);
    _player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_player.frame.size.width/2.0f];
    _player.zPosition = 10;
    _fadeIn = [SKAction fadeInWithDuration:.5];
    _fadeOut = [SKAction fadeOutWithDuration:.5];
    [[self physicsWorld] setGravity:CGVectorMake(0.0, 0.0)];
    
    [self newGameValues];
}

-(void)createGameStartMenu {
    
    _gameTitle = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    _startButton = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    _optionButton = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    _scoresButton = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    _exitButton = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    
    _gameTitle.text = @"Bubble Game";
    _gameTitle.fontSize = 50;
    _gameTitle.position = CGPointMake(CGRectGetMidX(self.frame), 230);
    
    _startButton.text = @"Start Game";
    _startButton.fontSize = 18;
    _startButton.position = CGPointMake(CGRectGetMidX(self.frame), 160);
    _startButton.name = @"Start Game";
    
    _optionButton.text = @"Options";
    _optionButton.fontSize = 18;
    _optionButton.position = CGPointMake(CGRectGetMidX(self.frame), 130);
    _optionButton.name = @"Options";
    
    _scoresButton.text = @"High Scores";
    _scoresButton.fontSize = 18;
    _scoresButton.position = CGPointMake(CGRectGetMidX(self.frame), 100);
    _scoresButton.name = @"High Scores";
    
    _exitButton.text = @"Exit Game";
    _exitButton.fontSize = 18;
    _exitButton.position = CGPointMake(CGRectGetMidX(self.frame), 70);
    _exitButton.name = @"Exit Game";
    
}

-(void)fadeinGameStartMenu {
    [self addChild:_gameTitle];
    [self addChild:_startButton];
    [self addChild:_optionButton];
    [self addChild:_scoresButton];
    [self addChild:_exitButton];
    [_gameTitle runAction:_fadeIn];
    [_startButton runAction:_fadeIn];
    [_optionButton runAction:_fadeIn];
    [_scoresButton runAction:_fadeIn];
    [_exitButton runAction:_fadeIn];
}

-(void)fadeOutGameStartMenu {
    [_gameTitle runAction:_fadeOut];
    [_startButton runAction:_fadeOut];
    [_optionButton runAction:_fadeOut];
    [_scoresButton runAction:_fadeOut];
    [_exitButton runAction:_fadeOut];
    [_gameTitle removeFromParent];
    [_startButton removeFromParent];
    [_optionButton removeFromParent];
    [_scoresButton removeFromParent];
    [_exitButton removeFromParent];
    
    
}

-(void)createMenu {
    _playTitle = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    _yes = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    _no = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    
    _playTitle.text = @"Play Again?";
    _playTitle.fontSize = 50;
    _playTitle.position = CGPointMake(CGRectGetMidX(self.frame), 230);
    _playTitle.alpha = 0.0;
    
    _no.text = @"Yes";
    _no.fontSize = 18;
    _no.position = CGPointMake(CGRectGetMidX(self.frame) - 100, CGRectGetMidY(self.frame) - 50);
    _no.name = @"Play Again";
    _no.alpha = 0.0;
    
    _yes.text = @"No";
    _yes.fontSize = 18;
    _yes.position = CGPointMake(CGRectGetMidX(self.frame) + 100, CGRectGetMidY(self.frame) - 50);
    _yes.name = @"Menu";
    _yes.alpha = 0.0;
}

-(void)fadeInMenu {
    [self addChild:_playTitle];
    [self addChild:_yes];
    [self addChild:_no];
    [_playTitle runAction:_fadeIn];
    [_yes runAction:_fadeIn];
    [_no runAction:_fadeIn];
    
    for(int i = 0; i < [enemyNodes count]; i++){
        [[[enemyNodes objectAtIndex:i] enSprite] runAction: _fadeOut];
    }
}

-(void)fadeOutMenu {
    [_playTitle runAction: _fadeOut];
    [_yes runAction: _fadeOut];
    [_no runAction: _fadeOut];
    [_playTitle removeFromParent];
    [_yes removeFromParent];
    [_no removeFromParent];
}

-(void)createOptionsMenu {
    _optionsTitleLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    _optionsMusicLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    _optionsEffectsLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    _optionsBackLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    
    
    _optionsTitleLabel.text = @"Options";
    _optionsTitleLabel.fontSize = 50;
    _optionsTitleLabel.position = CGPointMake(CGRectGetMidX(self.frame), 230);
    _optionsTitleLabel.name = @"Options";
    
    _optionsMusicLabel.text = @"Music";
    _optionsMusicLabel.fontSize = 18;
    _optionsMusicLabel.position = CGPointMake(CGRectGetMidX(self.frame), 130);
    _optionsMusicLabel.name = @"Music";
    
    _optionsEffectsLabel.text = @"Sound Effects";
    _optionsEffectsLabel.fontSize = 18;
    _optionsEffectsLabel.position = CGPointMake(CGRectGetMidX(self.frame), 100);
    _optionsEffectsLabel.name = @"Sound Effects";
    
    _optionsBackLabel.text = @"Back";
    _optionsBackLabel.fontSize = 18;
    _optionsBackLabel.position = CGPointMake(CGRectGetMidX(self.frame), 70);
    _optionsBackLabel.name = @"Back";
}


-(void)setUpBackground{
    NSArray *temp = [[NSArray alloc] initWithObjects:@"planetLayer1",@"planetLayer2",@"backgroundLayer2",@"backgroundLayer1", nil];
    _ourBackground = [[ParallaxBackground alloc] initFromLayerArray:temp inScene:self];
    if(![_ourBackground setParralaxSpeedRatioArray:[[NSArray alloc] initWithObjects:@1,@.6,@.4, @0, nil]])
        NSLog(@"Falied");
    [_ourBackground setXSpeed:0 andYSpeed:-BACKGROUND_SPEED];
}

-(void)fadeInOptions {
    [self addChild:_optionsTitleLabel];
    [self addChild:_optionsMusicLabel];
    [self addChild:_optionsEffectsLabel];
    [self addChild:_optionsBackLabel];
    [_optionsTitleLabel runAction:_fadeIn];
    [_optionsMusicLabel runAction:_fadeIn];
    [_optionsEffectsLabel runAction:_fadeIn];
    [_optionsBackLabel runAction:_fadeIn];
    
}

-(void)fadeOutOptions {
    [_optionsTitleLabel runAction: _fadeOut];
    [_optionsMusicLabel runAction: _fadeOut];
    [_optionsEffectsLabel runAction: _fadeOut];
    [_optionsBackLabel runAction: _fadeOut];
    [_optionsTitleLabel removeFromParent];
    [_optionsMusicLabel removeFromParent];
    [_optionsEffectsLabel removeFromParent];
    [_optionsBackLabel removeFromParent];
}

-(void)createScoreMenu {
    _highScoresNode = [SKNode node];
    _highScoresArray = [[NSMutableArray alloc] initWithCapacity:10];
    int count = 1;
    
    _scoreBackLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    _scoreTitleLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
    
    _scoreTitleLabel.text = @"High Scores";
    _scoreTitleLabel.fontSize = 20;
    _scoreTitleLabel.position = CGPointMake(CGRectGetMidX(self.frame), 290);
    
    _scoreBackLabel.text = @"Back";
    _scoreBackLabel.fontSize = 18;
    _scoreBackLabel.position = CGPointMake(CGRectGetMidX(self.frame), 15);
    _scoreBackLabel.name = @"ScoreBack";
    
    for (int n=0; n<=9; n++) {
        _scoreRankLabel =[[SKLabelNode alloc] init];
        _scoreRankLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLightItalic"];
        [_scoreRankLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
        _scoreRankLabel.fontSize = 14;
        _scoreRankLabel.position = CGPointMake(CGRectGetMidX(self.frame) - CGRectGetMaxX(self.frame)/12, 286-24*count);
        
        [_highScoresArray insertObject:_scoreRankLabel atIndex:n];
        count++;
        [_highScoresNode addChild:[_highScoresArray objectAtIndex:n]];
    }
    [self updateScoreMenu];
}

-(void)updateScoreMenu {
    _numberFormatter = [[NSNumberFormatter alloc] init];
    [_numberFormatter setPositiveFormat:@"##,###,###"];
    int count = 1;
    for (int n=0; n<=9; n++) {
        if([[ourDelegate highScores] count] > n){
            [[_highScoresArray objectAtIndex:n] setText:[NSString stringWithFormat:@"%d\t \t%@", count,
                                                         [_numberFormatter stringFromNumber:[NSNumber numberWithInteger:
                                                                                             [[[ourDelegate highScores]objectAtIndex:n] integerValue]]]]];
        }
        else {
            [[_highScoresArray objectAtIndex:n] setText:[NSString stringWithFormat:@"%d\t \t%d", count,0]];
        }
        count++;
    }
}



-(void)fadeInScores {
    [self addChild:_scoreTitleLabel];
    [self addChild:_scoreBackLabel];
    [self addChild:_highScoresNode];
    [_scoreTitleLabel runAction:_fadeIn];
    [_scoreBackLabel runAction:_fadeIn];
    [_highScoresNode runAction:_fadeIn];
}

-(void)fadeOutScores {
    [_scoreTitleLabel runAction: _fadeOut];
    [_scoreBackLabel runAction: _fadeOut];
    [_highScoresNode runAction: _fadeOut];
    [_scoreTitleLabel removeFromParent];
    [_scoreBackLabel removeFromParent];
    [_highScoresNode removeFromParent];
}


+(NSArray*)getEnemyArray{
    return (NSArray*)enemyNodes;
}

@end
