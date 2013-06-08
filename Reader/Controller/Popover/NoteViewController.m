//
//  NoteViewController.m
//  Reader
//
//  Created by 黄 鹏霄 on 13-6-8.
//  Copyright (c) 2013年 renweishe. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController ()

@end

@implementation NoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = CGSizeMake(350,600);
    self.view.backgroundColor = [UIColor whiteColor];
    
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 350, 40)];
    [self.view addSubview:searchBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
