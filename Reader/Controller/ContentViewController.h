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

@class RootViewController,GDataXMLElement;
@interface ContentViewController : UIViewController <PSStackedViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    DTAttributedTextView *contentView;
    BOOL foundContent;
    
    NSString *previous;
//    GDataXMLElement *current;
    NSString *next;
    
    UILabel *topLink;
    UILabel *bottomLink;
}
@property (nonatomic,strong) NSString *section;
@property (nonatomic,strong) NSString *articleId;
@property (nonatomic,strong) RootViewController *parentController;

- (void)loadData:(NSString *) aId;

@end
