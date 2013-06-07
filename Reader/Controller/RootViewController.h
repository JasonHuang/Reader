//
//  RootViewController.h
//  Reader
//
//  Created by 黄 鹏霄 on 13-6-4.
//  Copyright (c) 2013年 renweishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NaviViewController,DetailViewController,ContentViewController;

@interface RootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *m_menuTable;
    NSArray *m_menuContents;
    

    
    UIImageView *cover;
}

@property (nonatomic,strong) NaviViewController *navi;
@property (nonatomic,strong) DetailViewController *detail;
@property (nonatomic,strong) ContentViewController *content;

@end
