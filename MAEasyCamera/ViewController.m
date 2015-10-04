//
//  ViewController.m
//  MAEasyCamera
//
//  Created by YURI_JOU on 15/9/30.
//  Copyright © 2015年 oenius. All rights reserved.
//

#import "ViewController.h"
#import "MACameraController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

}

- (IBAction)handleClick:(id)sender
{
  MACameraController *controller = [[MACameraController alloc]init];
  controller.cancelBlock = ^(UIViewController *controller){
    [controller dismissViewControllerAnimated:YES completion:nil];
  };
  
  [self presentViewController:controller animated:YES completion:nil];
}

@end
