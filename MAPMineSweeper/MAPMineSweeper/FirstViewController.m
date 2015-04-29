//
//  FirstViewController.m
//  MAPMineSweeper
//
//  Created by Irfan Lone on 4/25/15.
//  Copyright (c) 2015 Irfan Programs. All rights reserved.
//

#import "FirstViewController.h"
#import "MAPGameView.h"

int noOfMines = 7;


@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    MAPGameView * gameView = [[MAPGameView alloc] init];
    self.view = gameView;
    [gameView placeMinesInTheGridRandomly:noOfMines];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
