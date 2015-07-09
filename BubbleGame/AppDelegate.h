//
//  AppDelegate.h
//  BubbleGame
//
//  Created by 3413 on 11/18/14.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <SpriteKit/SpriteKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Creation of backgound audio player object
@property (nonatomic) AVAudioPlayer *player;


//High Score Array for local Storage
@property (nonatomic, retain) NSMutableArray *highScores;

- (NSString*)archivePath;

@end

