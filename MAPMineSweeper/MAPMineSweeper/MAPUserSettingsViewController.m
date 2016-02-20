//
//  SecondViewController.m
//  MAPMineSweeper
//
//  Created by Irfan Lone on 10/25/14.
//  Copyright (c) 2014 Irfan Programs. All rights reserved.
//

#import "MAPUserSettingsViewController.h"
#import "MAPMainViewController.h"

NSString *const kGameLevelChangedNotification = @"GameLevelChangedNotification";
NSString *const kGameGridSizeChangedNotification = @"GameGridSizeChangedNotification";

@interface MAPUserSettingsViewController ()
@property (nonatomic, assign) MAPGameDifficultyLevel currentLevel;
@property (weak, nonatomic) IBOutlet UISlider *gameDifficultyLevelSlider;
@property (strong, nonatomic) IBOutlet UILabel *minTimeGameSolverPlayer;
@property (strong, nonatomic) IBOutlet UILabel *minimumTime;

@end

@implementation MAPUserSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentLevel = MAPGameDifficultyLevelMedium;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MAPHighestScore * highScore = [MAPMainViewController getHighScore];
    if (highScore) {
        self.minTimeGameSolverPlayer.text = highScore.player.name;
        self.minimumTime.text = [NSString stringWithFormat:@" %@",highScore.score];
    }
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

- (IBAction)gameGridSizeChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float sliderValue = (float)[slider value] * 100;    
    NSDictionary<NSString*,id> * userInfo = [NSDictionary dictionaryWithObject:@(sliderValue) forKey:@"gridSize"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kGameGridSizeChangedNotification object:self userInfo:userInfo];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
