//
//  SecondViewController.m
//  MAPMineSweeper
//
//  Created by Irfan Lone on 10/25/14.
//  Copyright (c) 2014 Irfan Programs. All rights reserved.
//

#import "MAPUserSettingsViewController.h"

NSString *const kGameLevelChangedNotification = @"GameLevelChangedNotification";

@interface MAPUserSettingsViewController ()
@property (nonatomic, assign) MAPGameDifficultyLevel currentLevel;
@property (weak, nonatomic) IBOutlet UISlider *gameDifficultyLevelSlider;

@end

@implementation MAPUserSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentLevel = MAPGameDifficultyLevelMedium;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)gameDifficultyLevelChanged:(id)sender {
    if (self.gameDifficultyLevelSlider.value  < 0.3) {
        self.currentLevel = MAPGameDifficultyLevelEasy;
    } else if (self.gameDifficultyLevelSlider.value < 0.55) {
        self.currentLevel = MAPGameDifficultyLevelMedium;
    } else if (self.gameDifficultyLevelSlider.value < 0.75) {
        self.currentLevel = MAPGameDifficultyLevelHard;
    } else {
        self.currentLevel = MAPGameDifficultyLevelExpert;
    }
    NSDictionary<NSString*,id> * userInfo = [NSDictionary dictionaryWithObject:@(self.currentLevel) forKey:@"gameLevel"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kGameLevelChangedNotification object:self userInfo:userInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
