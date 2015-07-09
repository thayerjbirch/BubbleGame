//
//  ParallaxBackground.h
//  ParallaxPlayground
//
//  Created by 3413 on 4/23/15.
//  Copyright (c) 2015 3413. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface ParallaxBackground : NSObject

-(id) initFromImageNamed:(NSString*)backgroundImage inScene:(SKScene*)theScene;
-(id) initFromLayerArray:(NSArray*)backgroundLayers inScene:(SKScene *)theScene;
-(BOOL)setParralaxSpeedRatioArray:(NSArray*)arrIn;
-(void)setXSpeed:(CGFloat)xIn andYSpeed:(CGFloat)yIn;
-(void)setXSpeed:(CGFloat)xIn;
-(void)setYSpeed:(CGFloat)yIn;
-(void)update;

@end

@interface ScrollingBackground : NSObject

-(id) init:(NSString*)backgroundImage andScene:(SKScene*)theScene andFrame:(CGRect)theFrame andSize:(CGSize)newSize;
-(void)updateAction:(CGVector)newAction;
-(void)setZAxis:(CGFloat) layer;

@end
