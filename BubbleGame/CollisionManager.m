//
//  CollisionManager.m
//  BubbleGame
//
//  Created by ikubilou on 5/24/15.
//
//

#import "CollisionManager.h"

@implementation CollisionContainer
NSMutableArray *nodesContained;

-(id)initWithRect:(CGRect)location{
    _bounds = location;
    return self;
}

-(void)update{
    for(int i = 0; i < nodesContained.count; i++){
        [[nodesContained objectAtIndex:i] update];
        [[[nodesContained objectAtIndex:i] enSprite] runAction:[_parent currentAction]];
        [self checkInBounds:[nodesContained objectAtIndex:i]];
    }
}

-(BOOL)checkInBounds:(EnemyNode*)targetNode{
    switch ((int)dirState) {
        case UP_STATE:
            if(_up!= nil && CGRectGetMaxY(targetNode.enSprite.frame) < CGRectGetMaxY(_bounds))
                return true;
            [self passUp:targetNode];
            break;
        case RIGHT_STATE:
            if(_right!= nil && CGRectGetMaxX(targetNode.enSprite.frame) < CGRectGetMaxX(_bounds))
                return true;
            [self passRight:targetNode];
            break;
        case DOWN_STATE:
            if(_down!=nil && CGRectGetMinY(targetNode.enSprite.frame) > CGRectGetMinY(_bounds))
                return true;
            [self passDown:targetNode];
            break;
        case LEFT_STATE:
            if(_left!=nil && CGRectGetMinX(targetNode.enSprite.frame) > CGRectGetMinX(_bounds))
                return true;
            [self passLeft:targetNode];
            break;
        default:
            break;
    }
    return false;
}

-(void)passUp:(EnemyNode*)targetNode{
    [nodesContained removeObject:targetNode];
    if(_up!=nil)
        [_up addNode:targetNode];
    else
        [[[_parent reuseNodes] objectForKey:targetNode.reuseIdentifier] addObject:targetNode];
}

-(void)passRight:(EnemyNode*)targetNode{
    [nodesContained removeObject:targetNode];
    if(_right!=nil)
        [_right addNode:targetNode];
    else
        [[[_parent reuseNodes] objectForKey:targetNode.reuseIdentifier] addObject:targetNode];
}

-(void)passDown:(EnemyNode*)targetNode{
    [nodesContained removeObject:targetNode];
    if(_down!=nil)
        [_down addNode:targetNode];
    else
        [[[_parent reuseNodes] objectForKey:targetNode.reuseIdentifier] addObject:targetNode];
}

-(void)passLeft:(EnemyNode*)targetNode{
    [nodesContained removeObject:targetNode];
    if(_left!=nil)
        [_left addNode:targetNode];
    else
        [[[_parent reuseNodes] objectForKey:targetNode.reuseIdentifier] addObject:targetNode];
}

-(void)addNode:(EnemyNode*)targetNode{
    [nodesContained addObject:targetNode];
}

@end

@implementation CollisionManager
NSArray* moves;

-(id)initInFrame:(CGRect)frame{
    _containers = [[NSMutableArray alloc] init];
    _reuseNodes = @{@"basic" : [[NSMutableArray alloc] init],
                    @"jugg" : [[NSMutableArray alloc] init],
                    @"gold" : [[NSMutableArray alloc] init],
                    };
    
    moves = [[NSArray alloc] initWithObjects:[SKAction moveByX:100.0 y:0.0 duration:1.0],//right
             [SKAction moveByX:-100.0 y:0.0 duration:1.0],//left
             [SKAction moveByX:-100.0 y:-00.0 duration:1.0],//up
             [SKAction moveByX:0.0 y:-100.0 duration:1.0],//down
             nil];
    
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    
    CGFloat width = frame.size.width / 3;
    CGFloat height = frame.size.height / 3;
    
    for(int y = 1; y <= 3; y++){
        maxY = y * height;
        for(int x = 1; x <= 3; x++){
            maxX = x * width;
            [_containers insertObject:[[CollisionContainer alloc] initWithRect:CGRectMake(minX, minY, maxX, maxY)] atIndex:(x+y-2)];//index -2 because we started both loops at 1
            minX = maxX;
        }
        minY = maxY;
    }
    
    [self setAdjacency];
    return self;
}

// Containers
// 0 | 1 | 2
// 3 | 4 | 5
// 6 | 7 | 8

-(void)setAdjacency{
    CollisionContainer *current = [_containers objectAtIndex:0];
    current.up = nil;
    current.right = [_containers objectAtIndex:1];
    current.down = [_containers objectAtIndex:3];
    current.left = nil;
    
    current = [_containers objectAtIndex:1];
    current.up = nil;
    current.right = [_containers objectAtIndex:2];
    current.down = [_containers objectAtIndex:4];
    current.left = [_containers objectAtIndex:0];
    
    current = [_containers objectAtIndex:2];
    current.up = nil;
    current.right = nil;
    current.down = [_containers objectAtIndex:5];
    current.left = [_containers objectAtIndex:1];
    
    current = [_containers objectAtIndex:3];
    current.up = [_containers objectAtIndex:0];
    current.right = [_containers objectAtIndex:4];
    current.down = [_containers objectAtIndex:6];
    current.left = nil;
    
    current = [_containers objectAtIndex:4];
    current.up = [_containers objectAtIndex:1];
    current.right = [_containers objectAtIndex:5];
    current.down = [_containers objectAtIndex:7];
    current.left = [_containers objectAtIndex:3];
    
    current = [_containers objectAtIndex:5];
    current.up = [_containers objectAtIndex:2];
    current.right = nil;
    current.down = [_containers objectAtIndex:8];
    current.left = [_containers objectAtIndex:4];
    
    current = [_containers objectAtIndex:6];
    current.up = [_containers objectAtIndex:3];
    current.right = [_containers objectAtIndex:7];
    current.down = nil;
    current.right = nil;
    
    current = [_containers objectAtIndex:7];
    current.up = [_containers objectAtIndex:4];
    current.right = [_containers objectAtIndex:8];
    current.down = nil;
    current.left = [_containers objectAtIndex:6];
    
    current = [_containers objectAtIndex:8];
    current.up = [_containers objectAtIndex:5];
    current.right = nil;
    current.down = nil;
    current.left = [_containers objectAtIndex:7];
}

-(void)update{
    for(int i = 0; i < _containers.count; i++){
        [[_containers objectAtIndex:i] update];
    }
}

+(void)setStaticDirection:(NSInteger*)direction{
    dirState = direction;
    [self setCurrentAction:*dirState];
}

+(void)setCurrentAction:(NSInteger)direction{
    currentAction = [moves objectAtIndex:direction];
}
@end


