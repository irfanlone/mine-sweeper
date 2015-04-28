//
//  MAPGameView.m
//  MAPMineSweeper
//
//  Created by Irfan Lone on 4/25/15.
//  Copyright (c) 2015 Irfan Programs. All rights reserved.
//

#import "MAPGameView.h"

static int kNumberOfRows    = 10;
static int kNumberOfColumns = 10;
static int MINE             = -1;
static int OPEN_CELL        = 101;
static int FLAGGED_CELL     = 102;
static int UNOPENED_CELL    = 103;
static int EMPTY_CELL       = 0;

CGRect mineFieldFrame;

int row;
int col;
int mineGrid [10][10];
int noOfMines               = 10;


@implementation MAPGameView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context    = UIGraphicsGetCurrentContext();
    CGRect frame            = CGRectMake(20, 150, self.frame.size.width - 40, self.frame.size.height - 300);
    mineFieldFrame          = frame;
    CGFloat width           = CGRectGetWidth( frame );
    CGFloat height          = CGRectGetHeight( frame );
    self.dh                 = (height) / kNumberOfRows;
    self.dw                 = (width) / kNumberOfColumns;
    
    CGContextBeginPath( context );
    for ( int i = 0;  i < kNumberOfRows + 1;  ++i )
    {
        // draw horizontal grid line
        CGContextMoveToPoint( context, frame.origin.x, frame.origin.y + (i * self.dh) );
        CGContextAddLineToPoint( context, frame. origin.x + width , frame.origin.y + (i * self.dh) );
    }
    for ( int i = 0;  i < kNumberOfColumns + 1;  ++i )
    {
        // draw vertical grid line
        CGContextMoveToPoint( context,frame.origin.x + (i * self.dw), frame.origin.y );
        CGContextAddLineToPoint( context, frame.origin.x + (i * self.dw), frame.origin.y + height );
    }
    [[UIColor redColor] setStroke];             // use gray as stroke color
    CGContextDrawPath( context, kCGPathStroke ); // execute collected drawing ops
    [self placeMinesInTheGridRandomly:noOfMines];
    
    
    UIFont *font = [UIFont fontWithName:@"Gillsans" size:16];
    
    NSDictionary *attrsDictionary =
    
    [NSDictionary dictionaryWithObjectsAndKeys:
     font, NSFontAttributeName,
     [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil];
    NSString *cell = [[NSNumber numberWithInt:10] stringValue];
    CGPoint xy = CGPointMake(190, 305);
    [cell drawAtPoint: xy withAttributes: attrsDictionary];

}

- (void) setTheGridRecursivelyWithRow:(NSInteger) row andColumn:(NSInteger) col
{
    NSInteger count = 0;
    NSInteger startingRow;
    NSInteger endingRow;
    NSInteger startingCol;
    NSInteger endingCol;
    
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
    
    if (row == 9) {
        endingRow = row;
    } else {
        endingRow = row + 1;
    }
    
    if (col == 9) {
        endingCol = col;
    } else {
        endingCol = col + 1;
    }

    
    for (int i = (int)startingRow; i < endingRow; ++i) {
        for (int j = (int)startingCol ; j < endingCol; ++j) {
            if (mineGrid[i][j] == MINE || mineGrid[i][j] == FLAGGED_CELL) {
                count++;
            }
        }
    }
    
    if (count == 0) {
        mineGrid[row][col] = EMPTY_CELL;
        for (int i = (int)startingRow; i < endingRow; ++i) {
            for (int j = (int)startingCol ; j < endingCol; ++j) {
                [self setTheGridRecursivelyWithRow:i andColumn:j];
            }
        }

    }
    else {
        mineGrid[row][col] = (int)count;
    }
    
}

- (void) placeMinesInTheGridRandomly:(NSInteger) noOfMines
{
    for (int mineCount = 0; mineCount < noOfMines; ++mineCount) {
        for (int i = 0; i < kNumberOfRows; i++) {
            int randomNumber = arc4random_uniform(kNumberOfRows);
            for (int j = 0 ; j < kNumberOfColumns; j++) {
                if (j == randomNumber)  {
                    mineGrid[i][j] = MINE;
                }
            }
        }
    }
}

- (void) tapSingleHandler: (UITapGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint locationTapped;
        locationTapped = [sender locationInView: self];
        float row = (locationTapped.x - mineFieldFrame.origin.x )/ self.dw;
        float col = (locationTapped.y - mineFieldFrame.origin.y)/ self.dh ;
        if (row < 0 || col < 0 ) {
            return;
        }
        if (row < 10 && col < 10) {
            NSLog(@"Single tap recognized");
            NSLog( @"row, col = %f, %f", row, col );
        }
    }
}

- (void) tapDoubleHandler: (UITapGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint locationTapped;
        locationTapped = [sender locationInView: self];
        float row = (locationTapped.x - mineFieldFrame.origin.x )/ self.dw;
        float col = (locationTapped.y - mineFieldFrame.origin.y)/ self.dh ;
        if (row < 0 || col < 0 ) {
            return;
        }
        if (row < 10 && col < 10) {
            NSLog(@"Double tap recognized");
            NSLog( @"row, col = %f, %f", row, col );
            [self setTheGridRecursivelyWithRow:row andColumn:col];
        }
    }
}

@end
