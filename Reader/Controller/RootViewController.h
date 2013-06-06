//
//  RootViewController.h
//  Reader
//
//  Created by 黄 鹏霄 on 13-6-4.
//  Copyright (c) 2013年 renweishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NaviViewController,DetailViewController;

@interface RootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *m_menuTable;
    NSArray *m_menuContents;
    
    NaviViewController *navi;
    DetailViewController *detail;
    
    UIImageView *cover;
}

@end
