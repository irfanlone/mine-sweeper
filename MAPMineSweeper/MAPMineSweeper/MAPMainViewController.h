//
//  FirstViewController.h
//  MAPMineSweeper
//
//  Created by Irfan Lone on 10/25/14.
//  Copyright (c) 2014 Irfan Programs. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * kNumberOfMinesPrefKey;
@interface MAPPlayer : NSObject<NSCoding>
@property (nonatomic, strong) NSString * name;

@end

@interface MAPHighestScore : NSObject<NSCoding>
@property (nonatomic, strong) MAPPlayer * player;
@property (nonatomic, strong) NSNumber * score;

@end

@interface MAPMainViewController : UIViewController<UIAlertViewDelegate>

+ (void)saveNewHighScore:(MAPHighestScore *)highScore;

+ (MAPHighestScore *)getHighScore;
@end

