//
//  MAPGameView.h
//  MAPMineSweeper
//
//  Created by Irfan Lone on 10/25/14.
//  Copyright (c) 2014 Irfan Programs. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kGameFinishedAlertNotification;

@interface MAPGameView : UIView

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithNoOfMines:(NSInteger)mines;

- (void)tapSingleHandler:(UITapGestureRecognizer *)sender;

- (void)tapDoubleHandler:(UITapGestureRecognizer *)sender;

@end
