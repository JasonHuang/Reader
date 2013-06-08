//
//  DetailViewController.h
//  Reader
//
//  Created by 黄 鹏霄 on 13-6-5.
//  Copyright (c) 2013年 renweishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "PSStackedViewDelegate.h"

@class RootViewController;
@interface DetailViewController : UIViewController <PSStackedViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *m_table;
    
    NSMutableArray *m_data;
    
}

@property (nonatomic,assign) NSInteger idx;
@property (nonatomic,assign) NSInteger cnt;
@property (nonatomic,strong) RootViewController *parentController;


- (void)reloadTableData;

@end
