//
//  ContentViewController.m
//  Reader
//
//  Created by 黄 鹏霄 on 13-6-7.
//  Copyright (c) 2013年 renweishe. All rights reserved.
//

#import "ContentViewController.h"
#import <PSStackedView/PSStackedView.h>
#import <GDataXML-HTML/GDataXMLNode.h>
#import <DTCoreText/DTCoreText.h>
#import <DTCoreText/DTAttributedTextView.h>

@interface ContentViewController ()

@end

@implementation ContentViewController
@synthesize articleId = _articleId,parentController = _parentController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    contentView = [[DTAttributedTextView alloc]initWithFrame:CGRectMake(20, 20, self.view.width-100, self.view.height-40)];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    [self loadData];
}

- (void)loadData
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"book" ofType:@"xml"];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding  error:NULL];
    if (!doc) {
        return;
    }
    
    NSArray *items = [doc nodesForXPath:@"//book/*/Article" error:NULL];
    for (GDataXMLElement *item in items) {
        GDataXMLNode *sequenceNumber = [item childAtIndex:0] ;
        GDataXMLNode *unitContent = [item childAtIndex:24];
        
        if (![[sequenceNumber stringValue] isEqualToString:_articleId]) {
            continue;
        }
        
        NSLog(@"%@ found",[sequenceNumber stringValue]);
        NSData *data = [[unitContent stringValue] dataUsingEncoding:NSUTF8StringEncoding];
        void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
            
            // the block is being called for an entire paragraph, so we check the individual elements
            
            for (DTHTMLElement *oneChildElement in element.childNodes)
            {
                NSLog(@"%@",[oneChildElement attributedString]);
                // if an element is larger than twice the font size put it in it's own block
                if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
                {
                    oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
                    oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
                    oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
                }
            }
        };
        
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.5], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:contentView.frame.size], DTMaxImageSize,
                                        @"Times New Roman", DTDefaultFontFamily,  @"purple", DTDefaultLinkColor, @"red", DTDefaultLinkHighlightColor, callBackBlock, DTWillFlushBlockCallBack, nil];
        

//        [options setObject:[NSURL fileURLWithPath:readmePath] forKey:NSBaseURLDocumentOption];
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
        contentView.attributedString = string;
    }
}


@end
