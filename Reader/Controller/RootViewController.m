//
//  RootViewController.m
//  Reader
//
//  Created by 黄 鹏霄 on 13-6-4.
//  Copyright (c) 2013年 renweishe. All rights reserved.
//

#import "RootViewController.h"
#import "UIImage+OverlayColor.h"
#import <PSStackedView/PSStackedView.h>
#include <QuartzCore/QuartzCore.h>
#import "MenuTableViewCell.h"
#import "AppDelegate.h"
#import "NaviViewController.h"
#import "DetailViewController.h"
#import <GDataXML-HTML/GDataXMLNode.h>


#define kMenuWidth 200
#define kCellText @"CellText"
#define kCellImage @"CellImage"

@interface RootViewController ()
@property (nonatomic, strong) UITableView *menuTable;
@property (nonatomic, strong) NSArray *cellContents;
@end

@implementation RootViewController
@synthesize menuTable = m_menuTable;
@synthesize cellContents = m_menuContents;


- (void)viewDidLoad
{
    [super viewDidLoad];

    // add example background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    // prepare menu content
    NSMutableArray *contents = [[NSMutableArray alloc] init];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"Example1",@""), kCellText, nil]];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"11-clock"], kCellImage, NSLocalizedString(@"Example2",@""), kCellText, nil]];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"15-tags"], kCellImage, NSLocalizedString(@" ",@""), kCellText, nil]];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"08-chat"], kCellImage, NSLocalizedString(@"<- Collapse",@""), kCellText, nil]];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"11-clock"], kCellImage, NSLocalizedString(@"Expand ->",@""), kCellText, nil]];
    [contents addObject:[NSDictionary dictionaryWithObjectsAndKeys:[UIImage invertImageNamed:@"15-tags"], kCellImage, NSLocalizedString(@"Clear All",@""), kCellText, nil]];
    self.cellContents = contents;
    
    // add table menu
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 60, self.view.height) style:UITableViewStylePlain];
    self.menuTable = tableView;
    
    [self.menuTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.menuTable.backgroundColor = [UIColor clearColor];
    self.menuTable.delegate = self;
    self.menuTable.dataSource = self;
    [self.view addSubview:self.menuTable];
    [self.menuTable reloadData];
    
    self.stackController.largeLeftInset = self.stackController.leftInset;
    
    NSLog(@"%d",self.stackController.largeLeftInset);
    NSLog(@"%d",self.stackController.leftInset);
    
//    NSString *path = [[NSBundle mainBundle]pathForResource:@"back" ofType:@"xml"];
//    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding  error:NULL];
//    if (doc) {
//        NSArray *employees = [doc nodesForXPath:@"//back_of_book/Article/Unit_Words" error:NULL];
//        for (GDataXMLElement *employe in employees) {
//            NSLog(@"%@",[employe stringValue]);
//        }
//    }


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    cover = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cover"]];
    cover.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    [self.view addSubview:cover];

    [self.view bringSubviewToFront:cover];

    [UIView animateWithDuration:2 animations:^{
        cover.alpha = 0;
    }];
    [self performSelector:@selector(pushCatalog) withObject:nil afterDelay:2];
}

- (void)pushCatalog
{
    if (!navi) {
        navi = [[NaviViewController alloc] init];
        [XAppDelegate.stackController pushViewController:navi fromViewController:nil animated:YES];
    }
    if(!detail){
        detail = [[DetailViewController alloc] init];
        [XAppDelegate.stackController pushViewController:detail fromViewController:nil animated:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_menuContents count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ExampleMenuCell";
    
    MenuTableViewCell *cell = (MenuTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	cell.textLabel.text = [[m_menuContents objectAtIndex:indexPath.row] objectForKey:kCellText];
	cell.imageView.image = [[m_menuContents objectAtIndex:indexPath.row] objectForKey:kCellImage];
    
    //if (indexPath.row == 5)
    //    cell.enabled = NO;
    
    return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PSStackedViewController *stackController = XAppDelegate.stackController;
    UIViewController*viewController = nil;
    
    
    if (indexPath.row < 3) {
        // Pop everything off the stack to start a with a fresh app feature
        // DISABLED FOR DEBUGGING
        //        [stackController popToRootViewControllerAnimated:YES];
    }
    
    if (indexPath.row == 0) {
        viewController = [[NaviViewController alloc] init];
    }else if(indexPath.row == 1) {
        viewController = [[DetailViewController alloc] init];
    }else if(indexPath.row == 2) { // Twitter style
        viewController = [[NaviViewController alloc] init];
        viewController.view.width = roundf((self.view.width - stackController.leftInset)/2);
    }
    else if(indexPath.row == 3) {
        [stackController collapseStack:1 animated:YES];
    }else if(indexPath.row == 4) { // right
        [stackController expandStack:1 animated:YES];
    }else if(indexPath.row == 5) {
        while ([stackController.viewControllers count]) {
            [stackController popViewControllerAnimated:YES];
        }
    }
    
    if (viewController) {
        [XAppDelegate.stackController pushViewController:viewController fromViewController:nil animated:YES];
    }
}

@end
