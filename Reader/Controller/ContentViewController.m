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
        
        NSString *headerPath = [[NSBundle mainBundle]pathForResource:@"header" ofType:@"html"];
        NSString *header = [NSString stringWithContentsOfFile:headerPath encoding:NSUTF8StringEncoding error:NULL];
        
        NSString *footerPath = [[NSBundle mainBundle]pathForResource:@"footer" ofType:@"html"];
        NSString *footer = [NSString stringWithContentsOfFile:footerPath encoding:NSUTF8StringEncoding error:NULL];
        
        NSString *content = [unitContent stringValue];
        
//        content = @"<IMG id=\"P2-1\" />";
        
        content = [self processContent:content];
        
        NSLog(@"content:%@",content);
        
        NSString *html = [NSString stringWithFormat:@"%@%@%@",header,content,footer];
        
//        NSLog(@"%@",html);
        
        NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
        void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
            
            // the block is being called for an entire paragraph, so we check the individual elements
            
            for (DTHTMLElement *oneChildElement in element.childNodes)
            {
                // if an element is larger than twice the font size put it in it's own block
                if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
                {
                    oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
                    oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
                    oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
                }
            }
        };
        
//        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.5], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:contentView.frame.size], DTMaxImageSize,
//                                        @"Times New Roman", DTDefaultFontFamily,  @"purple", DTDefaultLinkColor, @"red", DTDefaultLinkHighlightColor, callBackBlock, DTWillFlushBlockCallBack, nil];
//        

//        [options setObject:[NSURL fileURLWithPath:readmePath] forKey:NSBaseURLDocumentOption];
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:NULL documentAttributes:NULL];
        contentView.attributedString = string;
    }
}

- (NSString *)processContent:(NSString *)html
{
    __block NSString *content = html;
    
    NSString *regexToReplace = @"<(h\\d) id=\"(.*)\">(.*)</\\1>"; //id=\"(.*)\">(.*)<\\/h\1>";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexToReplace
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    content = [regex stringByReplacingMatchesInString:content
                                              options:0
                                                range:NSMakeRange(0, content.length)
                                         withTemplate:[NSString stringWithFormat:@"<div class='.$1' id='$2'>$3</div>"]];
    regexToReplace = @"<IMG id=\"(.*)\" />";
    regex = [NSRegularExpression regularExpressionWithPattern:regexToReplace
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    int length = content.length;
    NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, length)];
    
//    [regex enumerateMatchesInString:content options:0 range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
    for (NSTextCheckingResult *result in matches) {
        NSRange range = [result rangeAtIndex:0];
        NSRange range1 = [result rangeAtIndex:1];
        NSString *imgStr = [content substringWithRange:range1];
        NSString *xmlPath = [[NSBundle mainBundle]pathForResource:imgStr ofType:@"xml"];
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:xmlPath] encoding:NSUTF8StringEncoding  error:NULL];
        if (!doc) {
            break;
        }
        
        NSArray *items = [doc nodesForXPath:@"//Pic/Pic_Size" error:NULL];
        GDataXMLElement *item = [items objectAtIndex:0];
        NSString *picSize = [item stringValue];
        NSArray *sizes = [picSize componentsSeparatedByString:@","];
        NSInteger width = [[sizes objectAtIndex:0] integerValue];
        NSInteger height = [[sizes objectAtIndex:1]integerValue];
        
        float ratio = contentView.frame.size.width / width;
        
        float het = height * ratio;
        
        NSString *replacement = [NSString stringWithFormat:@"<img id='%@' src='%@.jpg' width='%fpx' height='%fpx'/>",imgStr,imgStr,contentView.size.width,het];
        
        NSLog(@"%@",replacement);
        
        content = [content stringByReplacingCharactersInRange:range withString:replacement];
        content = [self processContent:content];
    }
//    }];
//
//    content = [regex stringByReplacingMatchesInString:content
//                                              options:0
//                                                range:NSMakeRange(0, content.length)
//                                         withTemplate:[NSString stringWithFormat:@"<img id='$1' src='$1.jpg'/>"]];
    return content;
}

@end
