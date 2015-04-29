//
//  MAPGameView.m
//  MAPMineSweeper
//
//  Created by Irfan Lone on 4/25/15.
//  Copyright (c) 2015 Irfan Programs. All rights reserved.
//

#import "MAPGameView.h"

static int kNumberOfRows        = 10;
static int kNumberOfColumns     = 10;
static int MINE                 = -1;
static int FLAGGED_CELL         = 102;
static int UNOPEND_CELL         = 103;
static int OPENED_EMPTY_CELL    = 0;


CGRect mineFieldFrame;

int row;
int col;
int mineGrid [10][10];


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
    
    UIFont *font = [UIFont fontWithName:@"arial" size:16];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,[NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, nil];
    for (int i = 0; i < kNumberOfColumns; ++i) {
        for (int j = 0; j < kNumberOfRows; ++j) {
            
            CGRect imageRect = CGRectMake(mineFieldFrame.origin.x + (j*self.dw), mineFieldFrame.origin.y + (i*self.dh), self.dh, self.dw);
            CGPoint xy = CGPointMake(mineFieldFrame.origin.x + (j*self.dw) + (self.dw/3), mineFieldFrame.origin.y + (i*self.dh) + (self.dh/3));

            if (mineGrid[i][j] == FLAGGED_CELL) {
                UIImage * flagImage = [UIImage imageNamed:@"flagButton.png"];
                [flagImage drawInRect:imageRect];
            }
            
            else if(mineGrid[i][j] == MINE || mineGrid[i][j] == UNOPEND_CELL){
                UIImage * unOpenedCellImage = [UIImage imageNamed:@"cell.png"];
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
        }
    }

    
    
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
}

- (void) setTheGridRecursivelyWithRow:(NSInteger) row andColumn:(NSInteger) col
{
    if (mineGrid[row][col] != MINE && mineGrid[row][col] != FLAGGED_CELL && mineGrid[row][col] != OPENED_EMPTY_CELL) {
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
            if (row == kNumberOfRows-1) {
                endingRow = row;
            } else {
                endingRow = row + 1;
            }
            if (col == kNumberOfColumns-1) {
                endingCol = col;
            } else {
                endingCol = col + 1;
            }
            
            for (int i = (int)startingRow; i <= endingRow; ++i) {
                for (int j = (int)startingCol ; j <= endingCol; ++j) {
                    if (mineGrid[i][j] == MINE || mineGrid[i][j] == FLAGGED_CELL) {
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
            } else
            {
                mineGrid[row][col] = (int)count;
            }
        }
    }
}

- (void) placeMinesInTheGridRandomly:(NSInteger) noOfMines
{
    for (int i = 0; i < kNumberOfColumns; ++i) {
        for (int j = 0; j < kNumberOfRows; ++j) {
            mineGrid[i][j] = UNOPEND_CELL;
        }
    }
    for (int mineCount = 0; mineCount < noOfMines; ++mineCount) {
        int randomNumber1 = arc4random_uniform(kNumberOfRows)%kNumberOfRows;
        int randomNumber2 = arc4random_uniform(kNumberOfColumns)%kNumberOfColumns;
        mineGrid[randomNumber1][randomNumber2] = MINE;
    }
}

- (void) gameOver
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                 message:@"no message"
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil, nil];
    [alertView show];
}

- (void) tapSingleHandler: (UITapGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint locationTapped;
        locationTapped = [sender locationInView: self];
        float col = (locationTapped.x - mineFieldFrame.origin.x )/ self.dw;
        float row = (locationTapped.y - mineFieldFrame.origin.y)/ self.dh ;
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
                [self gameOver];
            }
            [self setTheGridRecursivelyWithRow:row andColumn:col];
        }
    }
    [self setNeedsDisplay];
}

- (void) tapDoubleHandler: (UITapGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint locationTapped;
        locationTapped = [sender locationInView: self];
        float col = (locationTapped.x - mineFieldFrame.origin.x )/ self.dw;
        float row = (locationTapped.y - mineFieldFrame.origin.y)/ self.dh ;
        if (row < 0 || col < 0 ) {
            return;
        }
        if (row < 10 && col < 10) {
            self.row = row;
            self.col = col;
            NSLog(@"Double tap recognized");
            NSLog( @"row, col = %f, %f", row, col );
            mineGrid[self.row][self.col] = FLAGGED_CELL;
        }
    }
    [self setNeedsDisplay];
}

@end
