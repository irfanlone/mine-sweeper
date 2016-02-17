//
//  MAPGameView.h
//  MAPMineSweeper
//
//  Created by Irfan Lone on 10/25/14.
//  Copyright (c) 2014 Irfan Programs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAPMainViewController;
@interface MAPGameView : UIView

@property (nonatomic, assign) CGFloat dw, dh;  // width and height of cell
@property (nonatomic, assign) CGFloat x, y;    // touch point coordinates
@property (nonatomic, assign) int row, col;    // selected cell in cell grid
@property (nonatomic, strong) MAPMainViewController * FirstViewController;


- (void)tapSingleHandler:(UITapGestureRecognizer *)sender;
- (void)tapDoubleHandler:(UITapGestureRecognizer *)sender;
- (void)placeMinesInTheGridRandomly:(NSInteger)noOfMines;

@end
