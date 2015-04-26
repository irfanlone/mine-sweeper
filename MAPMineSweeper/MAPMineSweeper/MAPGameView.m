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
CGRect mineFieldFrame;

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
    [[UIColor whiteColor] setStroke];             // use gray as stroke color
    CGContextDrawPath( context, kCGPathStroke ); // execute collected drawing ops

    
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
        }
    }
}

@end
