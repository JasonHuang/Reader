//
//  ContentViewController.h
//  Reader
//
//  Created by 黄 鹏霄 on 13-6-7.
//  Copyright (c) 2013年 renweishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "PSStackedViewDelegate.h"
#import <DTCoreText/DTAttributedTextView.h>

@class RootViewController;
@interface ContentViewController : UIViewController <PSStackedViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    DTAttributedTextView *contentView;
}
@property (nonatomic,strong) NSString *section;
@property (nonatomic,strong) NSString *articleId;
@property (nonatomic,strong) RootViewController *parentController;

- (void)loadData;

@end
