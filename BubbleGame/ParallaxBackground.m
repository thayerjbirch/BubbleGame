//
//  ParallaxBackground.m
//  ParallaxPlayground
//
//  Created by 3413 on 4/23/15.
//  Copyright (c) 2015 3413. All rights reserved.
//

#import "ParallaxBackground.h"
@interface ParallaxBackground()
    @property (nonatomic) CGFloat xSpeed;
    @property (nonatomic) CGFloat ySpeed;
    @property NSMutableArray* backgroundLayerArray;
    @property NSArray* parallaxSpeedRatioArray;
    @property SKScene* gameScene;
    @property CGRect frame;
    @property CGSize nodeSize;

    -(void)updateActions;
    -(void)setScene:(SKScene*)theScene;
    -(CGSize)findNodeSize:(NSString*)textureIn;
    -(void)buildDefaulParallaxSpeedRatioArray;
@end

@implementation ParallaxBackground

-(id) initFromImageNamed:(NSString*)backgroundImage inScene:(SKScene*)theScene{
    NSArray *tempArray = [[NSArray alloc] initWithObjects:backgroundImage, nil];
    self = [self initFromLayerArray:tempArray inScene:theScene];
    return self;
}

-(id) initFromLayerArray:(NSArray*)backgroundLayers inScene:(SKScene *)theScene{
    _backgroundLayerArray = [[NSMutableArray alloc] init];
    [self setScene:theScene];
    for(int i = 0; i < backgroundLayers.count; i++){
        _nodeSize = [self findNodeSize:[backgroundLayers objectAtIndex:i]];
        ScrollingBackground *newLayer = [[ScrollingBackground alloc] init:[backgroundLayers objectAtIndex:i]
                                                                 andScene:_gameScene andFrame:_frame andSize:_nodeSize];
        [newLayer setZAxis:(CGFloat)-i];
        [_backgroundLayerArray insertObject:newLayer atIndex:i];
    }
    [self buildDefaulParallaxSpeedRatioArray];
    return self;
}

-(CGSize)findNodeSize:(NSString*)textureIn{
    SKSpriteNode *theImage = [SKSpriteNode spriteNodeWithImageNamed:textureIn];
    double xSize = theImage.size.width;
    double ySize = theImage.size.height;
    double sizeRatio = 0;
    if(xSize > ySize){
        sizeRatio = _frame.size.height / ySize;
    } else {
        sizeRatio = _frame.size.width / xSize;
    }
    if(sizeRatio > 1)
        return CGSizeMake(_frame.size.width * sizeRatio, _frame.size.height * sizeRatio);
    else
        return CGSizeMake(_frame.size.width, _frame.size.height);
}

-(void)update{
    for(int i = 0; i < _backgroundLayerArray.count; i++){
        [[_backgroundLayerArray objectAtIndex:i] update];
    }
}

-(void)setScene:(SKScene *)theScene{
    if(!_gameScene)
        _gameScene = theScene;
    _frame = [_gameScene frame];
}

-(void)setXSpeed:(CGFloat)xIn{
    _xSpeed = xIn;
    [self updateActions];
}

-(void) setYSpeed:(CGFloat)yIn{
    _ySpeed = yIn;
    [self updateActions];
}

-(void) setXSpeed:(CGFloat)xIn andYSpeed:(CGFloat)yIn{
    _xSpeed = xIn;
    _ySpeed = yIn;
    [self updateActions];
}

-(void)updateActions{
    for(int i = 0; i < _backgroundLayerArray.count; i++){
        NSNumber *scalar = [_parallaxSpeedRatioArray objectAtIndex:i];
        CGVector newActionVector = CGVectorMake(_xSpeed * scalar.floatValue, _ySpeed * scalar.floatValue);
        [[_backgroundLayerArray objectAtIndex:i] updateAction:newActionVector];
    }
}
-(BOOL)setParralaxSpeedRatioArray:(NSArray*)arrIn{
    if(arrIn.count != _backgroundLayerArray.count){
        return false;
    }
    else{
        _parallaxSpeedRatioArray = [[NSArray alloc] initWithArray:arrIn];
        [self updateActions];
    }
    return true;
}

-(void)buildDefaulParallaxSpeedRatioArray{
    NSMutableArray *builderArray = [[NSMutableArray alloc] init];
    NSNumber *currentRatio = [NSNumber numberWithFloat:1.0];
    for (int i = 0; i < [_backgroundLayerArray count]; i++) {
        [builderArray insertObject:currentRatio atIndex:i];
        float temp = currentRatio.floatValue / 2;
        currentRatio = [NSNumber numberWithFloat:temp];
    }
    _parallaxSpeedRatioArray = builderArray;
}

@end


@interface ScrollingBackground()
    @property NSMutableArray* backgroundNodeArray;
    @property NSString* backgroundImage;
    @property SKAction* currentMovement;
    @property CGFloat dX;
    @property CGFloat dY;
    @property CGFloat xOffset;
    @property CGFloat yOffset;
    @property SKScene* gameScene;
    @property CGRect frame;
    @property CGRect innerBoundary;
    @property CGSize nodeSize;
    @property CGPoint trackingPoint;
@end

@implementation ScrollingBackground

/* array looks like 6 | 7 | 8
                    ---------
                    3 | 4 | 5
                    ---------
                    0 | 1 | 2*/

-(id) init:(NSString*)backgroundImage andScene:(SKScene*)theScene andFrame:(CGRect)theFrame andSize:(CGSize)newSize{
    _backgroundNodeArray = [[NSMutableArray alloc] initWithCapacity:9];
    _gameScene = theScene;
    _frame = theFrame;
    _nodeSize = newSize;
    _backgroundImage = backgroundImage;
    [self setUpTrackers];
    int xSize = _nodeSize.width;
    int ySize = _nodeSize.height;
    int count = 0;
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(_frame),
                                      CGRectGetMidY(_frame));
    for(int i = -1; i < 2; i++){        //this loop sets the positions of the images in the array
        for(int j = -1; j < 2; j++){    //such that 4 ends up in the 0,0 position
            SKSpriteNode *newNode = [SKSpriteNode spriteNodeWithImageNamed:_backgroundImage];
            newNode.size = _nodeSize;
            newNode.position= CGPointMake(centerPoint.x + (xSize * j),centerPoint.y + (ySize * i));
            [_backgroundNodeArray insertObject:newNode atIndex:count];
            [_gameScene addChild:newNode];
            count++;
        }
    }
    return self;
}

-(void)setUpTrackers{
     _trackingPoint = CGPointMake(_nodeSize.width / 2, _nodeSize.height / 2);
    _innerBoundary = CGRectMake(0,0,_nodeSize.width,_nodeSize.height);
}

-(void)update{
    for(int i = 0; i < _backgroundNodeArray.count; i++){
        [[_backgroundNodeArray objectAtIndex:i] runAction:_currentMovement];
    }
    [self swapLogic];
    
}

-(void)setZAxis:(CGFloat)layer{
    for(int i = 0; i < _backgroundNodeArray.count; i++){
        [[_backgroundNodeArray objectAtIndex:i] setZPosition:layer];
    }
}

-(void)swapLogic{
    _trackingPoint.x += _dX;
    _trackingPoint.y += _dY;
    if(_dX>0){
        if(_trackingPoint.x > CGRectGetMaxX(_innerBoundary)){
            [self translateLeft];
        }
    }else if(_dX < 0){
        if(_trackingPoint.x < CGRectGetMinX(_innerBoundary)){
            [self translateRight];
        }
    }
    
    if(_dY>0){
        if(_trackingPoint.y > CGRectGetMaxY(_innerBoundary)){
            [self translateDown];
        }
    }else if (_dY < 0){
        if(_trackingPoint.y < CGRectGetMinY(_innerBoundary)){
            [self translateUp];
        }
    }
}


-(void)translateLeft{
    float amountToMove = _nodeSize.width - 1;//we want to move the tracking point back into the box
    _trackingPoint.x -= amountToMove;   //we want to then move the nodes to the other side of the array
    amountToMove*=3;
    SKSpriteNode *holder = [_backgroundNodeArray objectAtIndex:2];
    [holder setPosition:CGPointMake(holder.position.x - amountToMove, holder.position.y)];
    holder = [_backgroundNodeArray objectAtIndex:5];
    [holder setPosition:CGPointMake(holder.position.x - amountToMove, holder.position.y)];
    holder = [_backgroundNodeArray objectAtIndex:8];
    [holder setPosition:CGPointMake(holder.position.x - amountToMove, holder.position.y)];
    [_backgroundNodeArray exchangeObjectAtIndex:0 withObjectAtIndex:1];
    [_backgroundNodeArray exchangeObjectAtIndex:3 withObjectAtIndex:4];
    [_backgroundNodeArray exchangeObjectAtIndex:6 withObjectAtIndex:7];
    [_backgroundNodeArray exchangeObjectAtIndex:0 withObjectAtIndex:2];
    [_backgroundNodeArray exchangeObjectAtIndex:3 withObjectAtIndex:5];
    [_backgroundNodeArray exchangeObjectAtIndex:6 withObjectAtIndex:8];
}

-(void)translateRight{
    float amountToMove = _nodeSize.width - 1;
    _trackingPoint.x += amountToMove;
    amountToMove*=3;
    SKSpriteNode *holder = [_backgroundNodeArray objectAtIndex:0];
    [holder setPosition:CGPointMake(holder.position.x + amountToMove, holder.position.y)];
    holder = [_backgroundNodeArray objectAtIndex:3];
    [holder setPosition:CGPointMake(holder.position.x + amountToMove, holder.position.y)];
    holder = [_backgroundNodeArray objectAtIndex:6];
    [holder setPosition:CGPointMake(holder.position.x + amountToMove, holder.position.y)];
    [_backgroundNodeArray exchangeObjectAtIndex:1 withObjectAtIndex:2];
    [_backgroundNodeArray exchangeObjectAtIndex:4 withObjectAtIndex:5];
    [_backgroundNodeArray exchangeObjectAtIndex:7 withObjectAtIndex:8];
    [_backgroundNodeArray exchangeObjectAtIndex:0 withObjectAtIndex:2];
    [_backgroundNodeArray exchangeObjectAtIndex:3 withObjectAtIndex:5];
    [_backgroundNodeArray exchangeObjectAtIndex:6 withObjectAtIndex:8];
}

-(void)translateUp{
    float amountToMove = _nodeSize.height - 1;
    _trackingPoint.y += amountToMove;
    amountToMove*=3;
    SKSpriteNode *holder = [_backgroundNodeArray objectAtIndex:0];
    [holder setPosition:CGPointMake(holder.position.x, holder.position.y + amountToMove)];
    holder = [_backgroundNodeArray objectAtIndex:1];
    [holder setPosition:CGPointMake(holder.position.x, holder.position.y + amountToMove)];
    holder = [_backgroundNodeArray objectAtIndex:2];
    [holder setPosition:CGPointMake(holder.position.x, holder.position.y + amountToMove)];
    [_backgroundNodeArray exchangeObjectAtIndex:3 withObjectAtIndex:6];
    [_backgroundNodeArray exchangeObjectAtIndex:4 withObjectAtIndex:7];
    [_backgroundNodeArray exchangeObjectAtIndex:5 withObjectAtIndex:8];
    [_backgroundNodeArray exchangeObjectAtIndex:0 withObjectAtIndex:6];
    [_backgroundNodeArray exchangeObjectAtIndex:1 withObjectAtIndex:7];
    [_backgroundNodeArray exchangeObjectAtIndex:2 withObjectAtIndex:8];
}

-(void)translateDown{
    float amountToMove = _nodeSize.height - 1;
    _trackingPoint.y -= amountToMove;
    amountToMove*=3;
    SKSpriteNode *holder = [_backgroundNodeArray objectAtIndex:6];
    [holder setPosition:CGPointMake(holder.position.x, holder.position.y - amountToMove)];
    holder = [_backgroundNodeArray objectAtIndex:7];
    [holder setPosition:CGPointMake(holder.position.x, holder.position.y - amountToMove)];
    holder = [_backgroundNodeArray objectAtIndex:8];
    [holder setPosition:CGPointMake(holder.position.x, holder.position.y - amountToMove)];
    [_backgroundNodeArray exchangeObjectAtIndex:0 withObjectAtIndex:3];
    [_backgroundNodeArray exchangeObjectAtIndex:1 withObjectAtIndex:4];
    [_backgroundNodeArray exchangeObjectAtIndex:2 withObjectAtIndex:5];
    [_backgroundNodeArray exchangeObjectAtIndex:0 withObjectAtIndex:6];
    [_backgroundNodeArray exchangeObjectAtIndex:1 withObjectAtIndex:7];
    [_backgroundNodeArray exchangeObjectAtIndex:2 withObjectAtIndex:8];
}


-(void)positionDump{
    for(int i = 0; i < _backgroundNodeArray.count; i++){
        NSLog(@"Node %d is at %f,%f",i,[[_backgroundNodeArray objectAtIndex:i] position].x,[[_backgroundNodeArray objectAtIndex:i] position].y);
    }
}
-(void)updateAction:(CGVector)newActionVector{
    _dX = newActionVector.dx;
    _dY  = newActionVector.dy;
    _currentMovement = [SKAction moveBy:newActionVector duration:1];
}

@end
