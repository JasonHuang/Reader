//
//  DetailViewController.m
//  Reader
//
//  Created by 黄 鹏霄 on 13-6-5.
//  Copyright (c) 2013年 renweishe. All rights reserved.
//

#import "DetailViewController.h"
#import <PSStackedView/PSStackedView.h>
#import <GDataXML-HTML/GDataXMLNode.h>
#import "RootViewController.h"
#import "ContentViewController.h"
#import "NaviViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize idx = _idx;
@synthesize cnt = _cnt;
@synthesize parentController = _parentController;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.width = PSIsIpad() ? 380 : 100;
    self.view.backgroundColor = [UIColor whiteColor];
    
    m_data = [[NSMutableArray alloc]initWithCapacity:1];
    
    m_table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStyleGrouped];
    m_table.delegate = self;
    m_table.dataSource = self;
    
    [self.view addSubview:m_table];
    
    [self loadData];
}

- (void)loadData
{
    [m_data removeAllObjects];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"book_catalog" ofType:@"xml"];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding  error:NULL];
    if (!doc) {
        return;
    }
    
    if (self.idx == 0) {
        NSArray *items = [doc nodesForXPath:@"//catalog/front_of_catalog/item" error:NULL];
        for (GDataXMLElement *item in items) {
            GDataXMLNode *itemId = [item childAtIndex:0] ;
            GDataXMLNode *layer = [item childAtIndex:1];
            GDataXMLNode *itemStr = [item childAtIndex:2];
            
            NSLog(@"%@",[itemStr stringValue]);
            NSDictionary *it = [NSDictionary dictionaryWithObjectsAndKeys:[itemId stringValue],@"id",[layer stringValue],@"layer",[itemStr stringValue],@"str", nil];
            [m_data addObject:it];
        }
    }else if (self.idx == (self.cnt-1)){
        NSArray *items = [doc nodesForXPath:@"//catalog/back_of_catalog/item" error:NULL];
        for (GDataXMLElement *item in items) {
            GDataXMLNode *itemId = [item childAtIndex:0] ;
            GDataXMLNode *layer = [item childAtIndex:1];
            GDataXMLNode *itemStr = [item childAtIndex:2];
            
            NSLog(@"%@",[itemStr stringValue]);
            NSDictionary *it = [NSDictionary dictionaryWithObjectsAndKeys:[itemId stringValue],@"id",[layer stringValue],@"layer",[itemStr stringValue],@"str", nil];
            [m_data addObject:it];
        }

    }else{
        NSArray *items = [doc nodesForXPath:@"//catalog/body_of_catalog/item" error:NULL];
        for (GDataXMLElement *item in items) {
            GDataXMLNode *itemId = [item childAtIndex:0] ;
            GDataXMLNode *layer = [item childAtIndex:1];
            GDataXMLNode *itemStr = [item childAtIndex:2];
            
            if ([[itemId stringValue] hasPrefix:[NSString stringWithFormat:@"%d-",self.idx]] ) {
                NSDictionary *it = [NSDictionary dictionaryWithObjectsAndKeys:[itemId stringValue],@"id",[layer stringValue],@"layer",[itemStr stringValue],@"str", nil];
                [m_data addObject:it];
            }
        }
    }
//        NSArray *items = [doc nodesForXPath:@"//catalog/front_of_catalog/item" error:NULL];
//        for (GDataXMLElement *item in items) {
//            GDataXMLNode *itemId = [item childAtIndex:0] ;
//            GDataXMLNode *layer = [item childAtIndex:1];
//            GDataXMLNode *itemStr = [item childAtIndex:2];
//            
//            NSLog(@"%@",[itemStr stringValue]);
//            NSDictionary *it = [NSDictionary dictionaryWithObjectsAndKeys:[itemId stringValue],@"id",[layer stringValue],@"layer",[itemStr stringValue],@"str", nil];
//            [m_data addObject:it];
//        }
//        
//
//        
//        items = [doc nodesForXPath:@"//catalog/back_of_catalog/item" error:NULL];
//        for (GDataXMLElement *item in items) {
//            GDataXMLNode *itemId = [item childAtIndex:0] ;
//            GDataXMLNode *layer = [item childAtIndex:1];
//            GDataXMLNode *itemStr = [item childAtIndex:2];
//            
//            NSLog(@"%@",[itemStr stringValue]);
//            NSDictionary *it = [NSDictionary dictionaryWithObjectsAndKeys:[itemId stringValue],@"id",[layer stringValue],@"layer",[itemStr stringValue],@"str", nil];
//            [m_data addObject:it];
//        }
//
//        
        [m_table reloadData];
//    }
    
    
}

- (void)reloadTableData
{
    [self loadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_data count];
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Example2Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *item = [m_data objectAtIndex:indexPath.row];
    NSString *txt = @"";
    for (int i=0 ; i < [[item objectForKey:@"layer"] intValue]; i++) {
        txt = [txt stringByAppendingFormat:@"%@",@"  "];
    }
    txt = [txt stringByAppendingFormat:@"%@",[item objectForKey:@"str"]];
	cell.textLabel.text = txt;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [m_data objectAtIndex:indexPath.row];
    NSString *articleId = [item objectForKey:@"id"];
//    if (articleId.length > 5) {
//        articleId = [articleId substringToIndex:5];
//    }
    NSLog(@"%@ clicked",articleId);
    
    if (self.idx == 0) {
        self.parentController.content.section = @"0";
    }else if (self.idx == (self.cnt-1)){
        self.parentController.content.section = @"2";
    }else {
        self.parentController.content.section = @"1";
    }

    NSLog(@"x,%f",self.stackController.floatIndex);
    
    if (self.stackController.floatIndex == 1) {
        [self.stackController collapseStack:1 animated:YES];
    }


    self.parentController.content.articleId = articleId;
    [self.parentController.content loadData:articleId];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSStackedViewDelegate

- (NSUInteger)stackableMinWidth; {
    return 100;
}



@end
