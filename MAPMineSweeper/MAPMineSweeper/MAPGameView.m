//
//  MAPGameView.m
//  MAPMineSweeper
//
//  Created by Irfan Lone on 10/25/14.
//  Copyright (c) 2014 Irfan Programs. All rights reserved.
//

#import "MAPGameView.h"
#import "MAPMainViewController.h"

static int MINE                 = -1;
static int FLAGGED_CELL         = 102;
static int FLAG_ON_MINE         = 103;
static int UNOPEND_CELL         = 104;
static int OPENED_EMPTY_CELL    = 0;

NSString *const kGameFinishedAlertNotification = @"GameFinishedAlertNotification";


@interface MAPGameView() {
    int mineGrid [12][12];
}
@property (nonatomic, assign) CGFloat dw, dh;  // width and height of cell
@property (nonatomic, assign) CGFloat x, y;    // touch point coordinates
@property (nonatomic, assign) int row, col;    // selected cell and row in grid
@property (nonatomic, assign) NSInteger noOfRows;
@property (nonatomic, assign) NSInteger noOfCols;
@property (nonatomic, strong) UILabel * gameTimerLabel;
@property (nonatomic, strong) UILabel * gameScoreLabel;
@property (nonatomic, strong) NSTimer * gameTimer;
@property (nonatomic, strong) NSNumber * currentScore;
@property (nonatomic, assign) NSInteger noOfMinesFlaggedCorrectly;
@property (nonatomic, assign) CGRect mineFieldFrame;
@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, assign) NSInteger totalMines;

@end

@implementation MAPGameView

- (instancetype)initWithNoOfMines:(NSInteger)mines rows:(NSInteger)noOfRows andCols:(NSInteger)noOfCols
{
    self = [super init];
    if (self) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor redColor]];
        [button addTarget:self action:@selector(newGamePressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"New Game" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        button.frame = CGRectMake(20.0, 55.0, 100.0, 32.0);
        [button.layer setCornerRadius:5.0f];
        [self addSubview:button];
        
        self.gameTimerLabel = [[UILabel alloc] init];
        [self.gameTimerLabel setBackgroundColor:[UIColor redColor]];
        self.gameTimerLabel.frame = CGRectMake(290.0, 55.0, 60.0, 32.0);
        self.gameTimerLabel.layer.masksToBounds = YES;
        [self.gameTimerLabel.layer setCornerRadius:5.0f];
        [self addSubview:self.gameTimerLabel];
        
        self.noOfRows = noOfRows;
        self.noOfCols = noOfCols;
        self.totalMines = mines;
        [self newGamePressed:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context    = UIGraphicsGetCurrentContext();
    CGRect frame            = CGRectMake(20, 150, self.frame.size.width - 40, self.frame.size.height - 300);
    self.mineFieldFrame     = frame;
    CGFloat width           = CGRectGetWidth( frame );
    CGFloat height          = CGRectGetHeight( frame );
    self.dh                 = (height) / self.noOfRows;
    self.dw                 = (width) / self.noOfCols;
    
    UIFont *font = [UIFont fontWithName:@"arial" size:16];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,[NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil];
    for (int i = 0; i < self.noOfCols; ++i) {
        for (int j = 0; j < self.noOfRows; ++j) {
            CGRect imageRect = CGRectMake(self.mineFieldFrame.origin.x + (j*self.dw), self.mineFieldFrame.origin.y + (i*self.dh), self.dw, self.dh);
            CGPoint xy = CGPointMake(self.mineFieldFrame.origin.x + (j*self.dw) + (self.dw/3), self.mineFieldFrame.origin.y + (i*self.dh) + (self.dh/3));
            if (mineGrid[i][j] == FLAGGED_CELL || mineGrid[i][j] == FLAG_ON_MINE) {
                UIImage * flagImage = [UIImage imageNamed:@"FlagButton"];
                [flagImage drawInRect:imageRect];
            }
            else if(mineGrid[i][j] == MINE || mineGrid[i][j] == UNOPEND_CELL){
                UIImage * unOpenedCellImage = [UIImage imageNamed:@"Cell"];
                [unOpenedCellImage drawInRect:imageRect];
            }
            else if(mineGrid[i][j] == OPENED_EMPTY_CELL){
                NSString *cell = @"";
                [cell drawAtPoint: xy withAttributes: attrsDictionary];
            }
            else {
                NSString *cell = [[NSNumber numberWithInt:mineGrid[i][j]] stringValue];
                [cell drawAtPoint: xy withAttributes: attrsDictionary];
            }
            if (self.gameOver) {
                if (mineGrid[i][j] == MINE || mineGrid[i][j] == FLAG_ON_MINE) {
                    UIImage * flagImage = [UIImage imageNamed:@"Mine"];
                    [flagImage drawInRect:imageRect];
                }
            }
        }
    }
    CGContextBeginPath( context );
    for (int i = 0; i < self.noOfRows+1; ++i) {
        // draw horizontal grid line
        CGContextMoveToPoint( context, frame.origin.x, frame.origin.y + (i * self.dh) );
        CGContextAddLineToPoint( context, frame. origin.x + width , frame.origin.y + (i * self.dh) );
    }
    for (int i = 0; i < self.noOfCols+1; ++i) {
        // draw vertical grid line
        CGContextMoveToPoint( context,frame.origin.x + (i * self.dw), frame.origin.y );
        CGContextAddLineToPoint( context, frame.origin.x + (i * self.dw), frame.origin.y + height );
    }
    [[UIColor blackColor] setStroke];             // use gray as stroke color
    CGContextDrawPath( context, kCGPathStroke ); // execute collected drawing ops
}

- (void)setTheGridRecursivelyWithRow:(NSInteger)row andColumn:(NSInteger)col {
    if (mineGrid[row][col] != MINE && mineGrid[row][col] != FLAGGED_CELL && mineGrid[row][col] != FLAG_ON_MINE && mineGrid[row][col] == UNOPEND_CELL) {
        NSInteger count         = 0;
        NSInteger startingRow   = 0;
        NSInteger endingRow     = 0;
        NSInteger startingCol   = 0;
        NSInteger endingCol     = 0;
        
        if (mineGrid[row][col] != MINE) {
            if (row == 0) {
                startingRow = row;
            } else {
                startingRow = row -1;
            }
            if (col == 0) {
                startingCol = col;
            } else {
                startingCol = col - 1;
            }
            if (row == self.noOfRows-1) {
                endingRow = row;
            } else {
                endingRow = row + 1;
            }
            if (col == self.noOfCols-1) {
                endingCol = col;
            } else {
                endingCol = col + 1;
            }
            for (int i = (int)startingRow; i <= endingRow; ++i) {
                for (int j = (int)startingCol ; j <= endingCol; ++j) {
                    if (mineGrid[i][j] == MINE || mineGrid[i][j] == FLAG_ON_MINE) {
                        count++;
                    }
                }
            }
            if (count == 0) {
                mineGrid[row][col] = OPENED_EMPTY_CELL;
                for (int i = (int)startingRow; i <= endingRow; ++i) {
                    for (int j = (int)startingCol ; j <= endingCol; ++j) {
                        [self setTheGridRecursivelyWithRow:i andColumn:j];
                    }
                }
            }
            else {
                mineGrid[row][col] = (int)count;
            }
        }
    }
}

- (void)placeMinesInTheGridRandomly:(NSInteger)noOfMines {
    for (int i = 0; i < self.noOfCols; ++i) {
        for (int j = 0; j < self.noOfRows; ++j) {
            mineGrid[i][j] = UNOPEND_CELL;
        }
    }
    for (int mineCount = 0; mineCount < noOfMines; ++mineCount) {
        NSInteger randomNumber1 = arc4random() % self.noOfRows;
        NSInteger randomNumber2 = arc4random() % self.noOfCols;
        mineGrid[randomNumber1][randomNumber2] = MINE;
    }
}

- (void)postGameFinishedNotificationWithStatus:(NSNumber*)win {
    [self.gameTimer invalidate];
    self.gameTimerLabel.text = [NSString stringWithFormat:@"    %@",self.currentScore];
    NSDictionary<NSString*,NSNumber*> * userInfo = @{@"win": win, @"score": self.currentScore};
    [[NSNotificationCenter defaultCenter] postNotificationName:kGameFinishedAlertNotification object:self userInfo:userInfo];
}

- (void)resetGame {
    self.gameOver = NO;
    self.noOfMinesFlaggedCorrectly = 0;
    [UIView animateWithDuration:.01 animations:^{
                         [self placeMinesInTheGridRandomly:self.totalMines];
                         [self setNeedsDisplay];
    } completion:^(BOOL finished){
    }];
}

- (void)tapSingleHandler:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint locationTapped;
        locationTapped = [sender locationInView: self];
        float col = (locationTapped.x - self.mineFieldFrame.origin.x )/ self.dw;
        float row = (locationTapped.y - self.mineFieldFrame.origin.y)/ self.dh ;
        if (row < 0 || col < 0 ) {
            return;
        }
        if (row < 10 && col < 10) {
            self.row = row;
            self.col = col;
            NSLog(@"Double tap recognized");
            NSLog( @"row, col = %f, %f", row, col );
            if (mineGrid[self.row][self.col] == FLAGGED_CELL) {
                mineGrid[self.row][self.col] = UNOPEND_CELL;
            } else if(mineGrid[self.row][self.col] == FLAG_ON_MINE) {
                mineGrid[self.row][self.col] = MINE;
                self.noOfMinesFlaggedCorrectly -= 1;
            } else if (mineGrid[self.row][self.col] == MINE) {
                mineGrid[self.row][self.col] = FLAG_ON_MINE;
                self.noOfMinesFlaggedCorrectly += 1;
            } else {
                mineGrid[self.row][self.col] = FLAGGED_CELL;
            }
            
            if (self.noOfMinesFlaggedCorrectly == self.totalMines) {
                [self postGameFinishedNotificationWithStatus:@(1)];
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)tapDoubleHandler:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint locationTapped;
        locationTapped = [sender locationInView: self];
        float col = (locationTapped.x - self.mineFieldFrame.origin.x )/ self.dw;
        float row = (locationTapped.y - self.mineFieldFrame.origin.y)/ self.dh ;
        if (row < 0 || col < 0 ) {
            return;
        }
        if (row < 10 && col < 10) {
            self.row = row;
            self.col = col;
            NSLog(@"Single tap recognized");
            NSLog( @"row, col = %f, %f", row, col );
            // game over condition
            if (mineGrid[self.row][self.col] == MINE) {
                [UIView beginAnimations:@"animationStringID'" context: nil];
                [UIView setAnimationDuration: 0.08];
                [UIView setAnimationRepeatCount: 8.0];
                CGRect frame = self.frame;
                frame.origin.x += 10; self.frame = frame; frame.origin.x -= 10; self.frame = frame;
                [UIView commitAnimations];
                [self postGameFinishedNotificationWithStatus:@(0)];
                self.gameOver = YES;
                [self setNeedsDisplay];
                return;
            }
            [self setTheGridRecursivelyWithRow:row andColumn:col];
        }
    }
    [self setNeedsDisplay];
}

- (void)newGamePressed:(id)sender {
    [self resetGame];
    [self.gameTimer invalidate];
    self.currentScore = @(0);
    self.gameTimerLabel.text = @"    0";
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
}

- (void)countDown:(NSTimer *)aTimer {
    NSInteger score = [self.currentScore integerValue];
    score += 1;
    self.gameTimerLabel.text = [NSString stringWithFormat:@"    %ld",score];
    self.currentScore = @(score);
}

@end
