//
//  MAPGameView.h
//  MAPMineSweeper
//
//  Created by Irfan Lone on 4/25/15.
//  Copyright (c) 2015 Irfan Programs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FirstViewController;
@interface MAPGameView : UIView

@property (nonatomic, assign) CGFloat dw, dh;  // width and height of cell
@property (nonatomic, assign) CGFloat x, y;    // touch point coordinates
@property (nonatomic, assign) int row, col;    // selected cell in cell grid
@property (nonatomic, strong) FirstViewController * FirstViewController;


- (void) tapSingleHandler: (UITapGestureRecognizer *) sender;
- (void) tapDoubleHandler: (UITapGestureRecognizer *) sender;
- (void) placeMinesInTheGridRandomly:(NSInteger) noOfMines;

@end
