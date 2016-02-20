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
@property (nonatomic, strong) MAPHighestScore * currentHighScore;
@property (nonatomic, assign) MAPGameDifficultyLevel currentGameLevel;
@property (nonatomic, strong) MAPPlayer * currentPlayer;
@property (nonatomic, assign) BOOL playerNameRequested;
@property (nonatomic, assign) NSInteger noOfRows;
@property (nonatomic, assign) NSInteger noOfCols;
@end

@implementation MAPPlayer
-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.name = [decoder decodeObjectForKey:@"name"];
    }
    return self;
}
@end

@implementation MAPHighestScore

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.player forKey:@"player"];
    [encoder encodeObject:self.score forKey:@"score"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.player = [decoder decodeObjectForKey:@"player"];
        self.score = [decoder decodeObjectForKey:@"score"];
    }
    return self;
}

@end

@implementation MAPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noOfRows = 10; // default values
    self.noOfCols = 10;
    self.playerNameRequested = NO;
    self.currentGameLevel = MAPGameDifficultyLevelMedium;
    self.currentHighScore = [[MAPHighestScore alloc] init];
    self.currentHighScore.score = @(INT_MAX);
    MAPHighestScore * highScore = [MAPMainViewController getHighScore];
    if (highScore) {
        self.currentHighScore = highScore;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameLevelChangedNotification:) name:kGameLevelChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameFinishedNotification:) name:kGameFinishedAlertNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameGridSizeChangedNotification:) name:kGameGridSizeChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self alertUserWithSettingsChange];
}

- (IBAction)newGamePressed:(id)sender {
    
    if (!self.playerNameRequested) {
        [self requestPlayerName];
    }
    self.gameView = [[MAPGameView alloc] initWithNoOfMines:[self getNumberOfMines] rows:self.noOfRows andCols:self.noOfCols];
    self.view = self.gameView;
    UIView *tapView = self.view;  // this is our PuzzleView object
    UITapGestureRecognizer *tapDoubleGR = [[UITapGestureRecognizer alloc] initWithTarget:tapView action:@selector(tapDoubleHandler:)];
    tapDoubleGR.numberOfTapsRequired = 2;         // set appropriate GR attributes
    [tapView addGestureRecognizer:tapDoubleGR];   // add GR to view
        UITapGestureRecognizer *tapSingleGR = [[UITapGestureRecognizer alloc] initWithTarget:tapView action:@selector(tapSingleHandler:)];
    tapSingleGR.numberOfTapsRequired = 1;         // set appropriate GR attributes
    [tapSingleGR requireGestureRecognizerToFail: tapDoubleGR];  // prevent single tap recognition on double-tap
    [tapView addGestureRecognizer:tapSingleGR];   // add GR to view
    self.view.backgroundColor = [UIColor whiteColor];
}

NSString *const kHighScoreKey = @"HighScoreKey";

+ (void)saveNewHighScore:(MAPHighestScore *)highScore {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:highScore];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:kHighScoreKey];
    [defaults synchronize];
}

+ (MAPHighestScore *)getHighScore {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:kHighScoreKey];
    MAPHighestScore *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

#pragma NOTIFICATIONS

- (void)gameLevelChangedNotification:(NSNotification *)notification {

    if ([[notification name] isEqualToString:kGameLevelChangedNotification]) {
        NSDictionary<NSString *, id> *userInfo = notification.userInfo;
        NSNumber *number = userInfo[@"gameLevel"];
        if (number) {
            self.currentGameLevel = (MAPGameDifficultyLevel)number.intValue;
        }
    }
}

- (void)gameGridSizeChangedNotification:(NSNotification *)notification {
  
    if ([[notification name] isEqualToString:kGameGridSizeChangedNotification]) {
        NSDictionary<NSString *, id> *userInfo = notification.userInfo;
        NSNumber *number = userInfo[@"gridSize"];
        if (number) {
            [self setRowsAndColumnsBasedOnNewSliderValue:[number integerValue]];
        }
    }
}

- (void)alertUserWithSettingsChange {
    UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Game settings changed" message:@" Start a new game or Cancel to complete the current game" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self newGamePressed:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [userAlert addAction:action];
    [userAlert addAction:cancelAction];
    [self presentViewController:userAlert animated:YES completion:nil];
}

- (void)gameFinishedNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:kGameFinishedAlertNotification]) {
        NSDictionary<NSString *, id> *userInfo = notification.userInfo;
        NSNumber *number = userInfo[@"win"];
        NSNumber *score = userInfo[@"score"];
        if ([number isEqualToNumber:@(1)]) {
            UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Congratulations!! You Won" message:[NSString stringWithFormat:@"Your score is %@",score] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self determineNewHighScore:score];
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

- (void)requestPlayerName {
    UIAlertController *userAlert = [UIAlertController alertControllerWithTitle:@"Please enter your name to play the game" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [userAlert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = @"your name";
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(!self.currentPlayer) {
            self.currentPlayer = [[MAPPlayer alloc] init];
            self.currentPlayer.name = ((UITextField *) [userAlert.textFields objectAtIndex:0]).text;
        }
        self.playerNameRequested = YES;
        [self newGamePressed:nil];
    }];
    [userAlert addAction:action];
    [self presentViewController:userAlert animated:YES completion:nil];
}

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

- (void)setRowsAndColumnsBasedOnNewSliderValue:(NSInteger)value {
    if (value < 25) {
        self.noOfRows = 6;
        self.noOfCols = 6;
    } else if (value < 50) {
        self.noOfRows = 8;
        self.noOfCols = 8;
    } else if (value < 85) {
        self.noOfRows = 10;
        self.noOfCols = 10;
    } else {
        self.noOfRows = 12;
        self.noOfCols = 12;
    }
}

- (void)determineNewHighScore:(NSNumber*)score {
    if (score < self.currentHighScore.score) {
        // means less time taken to solve the game
        // this is our new high score.
        MAPHighestScore * newHighScore = [[MAPHighestScore alloc] init];
        newHighScore.score = score;
        newHighScore.player = self.currentPlayer;
        [MAPMainViewController saveNewHighScore:newHighScore];
    }
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
