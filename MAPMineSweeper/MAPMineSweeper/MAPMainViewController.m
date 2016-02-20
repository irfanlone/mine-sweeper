//
//  FirstViewController.m
//  MAPMineSweeper
//
//  Created by Irfan Lone on 10/25/14.
//  Copyright (c) 2014 Irfan Programs. All rights reserved.
//

#import "MAPMainViewController.h"
#import "MAPGameView.h"
#import "MAPUserSettingsViewController.h"

@interface MAPMainViewController ()
@property (nonatomic, strong) MAPGameView * gameView;
@property (nonatomic, strong) MAPHighestScores * currentHighScore;
@property (nonatomic, assign) MAPGameDifficultyLevel currentGameLevel;

@end


@implementation MAPPlayer
@end

@implementation MAPHighestScores
@end

@implementation MAPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentGameLevel = MAPGameDifficultyLevelMedium;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameLevelChangedNotification:) name:kGameLevelChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameFinishedNotification:) name:kGameFinishedAlertNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Game Level Changed" message:@" Start a new game or Cancel to continue with the current game" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self newGamePressed:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [userAlert addAction:action];
    [userAlert addAction:cancelAction];
    [self presentViewController:userAlert animated:YES completion:nil];
}

- (IBAction)newGamePressed:(id)sender {
    
    self.gameView = [[MAPGameView alloc] initWithNoOfMines:[self getNumberOfMines]];
    self.view = self.gameView;
    
    UIView *tapView = self.view;  // this is our PuzzleView object
    UITapGestureRecognizer *tapDoubleGR = [[UITapGestureRecognizer alloc]
                                           initWithTarget:tapView action:@selector(tapDoubleHandler:)];
    tapDoubleGR.numberOfTapsRequired = 2;         // set appropriate GR attributes
    [tapView addGestureRecognizer:tapDoubleGR];   // add GR to view
    
    UITapGestureRecognizer *tapSingleGR = [[UITapGestureRecognizer alloc]
                                           initWithTarget:tapView action:@selector(tapSingleHandler:)];
    tapSingleGR.numberOfTapsRequired = 1;         // set appropriate GR attributes
    [tapSingleGR requireGestureRecognizerToFail: tapDoubleGR];  // prevent single tap recognition on double-tap
    [tapView addGestureRecognizer:tapSingleGR];   // add GR to view
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma NOTIFICATIONS

- (void)gameLevelChangedNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:kGameLevelChangedNotification]) {
        
        NSDictionary<NSString *, id> *userInfo = notification.userInfo;
        NSNumber *number = userInfo[@"gameLevel"];
        if (number) {
            self.currentGameLevel = (MAPGameDifficultyLevel)number.intValue;
        }
    }
}

- (void)gameFinishedNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:kGameFinishedAlertNotification]) {
        NSDictionary<NSString *, id> *userInfo = notification.userInfo;
        NSNumber *number = userInfo[@"win"];
        NSNumber *score = userInfo[@"score"];
        if ([number isEqualToNumber:@(1)]) {
            UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Congratulations!! You Won" message:[NSString stringWithFormat:@"Your score is %@",score] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self newGamePressed:nil];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
            [userAlert addAction:action];
            [userAlert addAction:cancelAction];
            [self presentViewController:userAlert animated:YES completion:nil];
        } else {
            UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Game Over!! You Lost" message:[NSString stringWithFormat:@"Your score is %@",score] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self newGamePressed:nil];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
            [userAlert addAction:action];
            [userAlert addAction:cancelAction];
            [self presentViewController:userAlert animated:YES completion:nil];
        }
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma private

- (NSInteger)getNumberOfMines {
    NSInteger mines = 0;
    if (self.currentGameLevel == MAPGameDifficultyLevelEasy) {
        mines = 5;
    } else if (self.currentGameLevel == MAPGameDifficultyLevelMedium) {
        mines = 15;
    } else if (self.currentGameLevel == MAPGameDifficultyLevelHard) {
        mines = 22;
    } else {
        mines = 30;
    }
    return mines;
}

- (void)refreshDisplay {
    [self.gameView removeFromSuperview];
    [self.view didMoveToSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
