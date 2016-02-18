//
//  FirstViewController.m
//  MAPMineSweeper
//
//  Created by Irfan Lone on 10/25/14.
//  Copyright (c) 2014 Irfan Programs. All rights reserved.
//

#import "MAPMainViewController.h"
#import "MAPGameView.h"

@interface MAPMainViewController ()
@property (nonatomic, strong) MAPGameView * gameView;
@end

@implementation MAPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}

- (IBAction)newGamePressed:(id)sender {
    
    self.gameView = [[MAPGameView alloc] init];
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

- (void)refreshDisplay {
    [self.gameView removeFromSuperview];
    [self.view didMoveToSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
