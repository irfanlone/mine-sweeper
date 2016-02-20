//
//  SecondViewController.h
//  MAPMineSweeper
//
//  Created by Irfan Lone on 10/25/14.
//  Copyright (c) 2014 Irfan Programs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MAPGameDifficultyLevel) {
    MAPGameDifficultyLevelEasy,
    MAPGameDifficultyLevelMedium,
    MAPGameDifficultyLevelHard,
    MAPGameDifficultyLevelExpert,
};

FOUNDATION_EXPORT NSString *const kGameLevelChangedNotification;
FOUNDATION_EXPORT NSString *const kGameGridSizeChangedNotification;

@interface MAPUserSettingsViewController : UIViewController


@end

