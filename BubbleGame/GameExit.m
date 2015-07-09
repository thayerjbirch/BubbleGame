//
//  GameExit.m
//  BubbleGame
//
//  Created by Ricky Peterson on 11/19/14.
//
//

#import "GameExit.h"

@implementation GameExit

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    SKView *exitView = (SKView *) self.view;
    exitView.paused = YES;
    
}

@end
