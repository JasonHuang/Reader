//
//  NaviViewController.m
//  Reader
//
//  Created by 黄 鹏霄 on 13-6-5.
//  Copyright (c) 2013年 renweishe. All rights reserved.
//

#import "NaviViewController.h"
#import <PSStackedView/PSStackedView.h>
#import <GDataXML-HTML/GDataXMLNode.h>
#import "RootViewController.h"
#import "DetailViewController.h"


@interface NaviViewController ()

@end

@implementation NaviViewController
@synthesize parentController = _parentController;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.width = PSIsIpad() ? 330 : 150;
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
    [m_data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"id",@"0",@"layer",@"关于本书",@"str", nil]];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"book_catalog" ofType:@"xml"];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding  error:NULL];
    if (doc) {
        NSArray *items = [doc nodesForXPath:@"//catalog/body_of_catalog/item" error:NULL];
        for (GDataXMLElement *item in items) {
            GDataXMLNode *itemId = [item childAtIndex:0] ;
            GDataXMLNode *layer = [item childAtIndex:1];
            GDataXMLNode *itemStr = [item childAtIndex:2];
            
            if ([[layer stringValue] isEqualToString:@"1"]) {
                NSLog(@"%@",[itemStr stringValue]);
                NSDictionary *it = [NSDictionary dictionaryWithObjectsAndKeys:[itemId stringValue],@"id",[layer stringValue],@"layer",[itemStr stringValue],@"str", nil];
                [m_data addObject:it];
            }
        }
        [m_data addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"id",@"0",@"layer",@"附录",@"str", nil]];
        [m_table reloadData];
    }
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
    
	cell.textLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"str"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.parentController.detail.idx = indexPath.row;
    self.parentController.detail.cnt = [m_data count];
    [self.parentController.detail reloadTableData];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSStackedViewDelegate

- (NSUInteger)stackableMinWidth; {
    return 100;
}

@end
