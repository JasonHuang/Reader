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
@synthesize articleId = _articleId,parentController = _parentController,section = _section;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    contentView = [[DTAttributedTextView alloc]initWithFrame:CGRectMake(20, 20, self.view.width-100, self.view.height-40)];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    self.section = @"0";
    self.articleId = @"1";
    
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
        NSArray *nodes = [item nodesForXPath:@"./Unit_content" error:NULL];
        if (!nodes || [nodes count] < 1) {
            return;
        }
        
        GDataXMLElement *item = [nodes objectAtIndex:0];
        
        GDataXMLNode *unitContent = [item childAtIndex:0];
        
        if (![[sequenceNumber stringValue] isEqualToString:_articleId]) {
            continue;
        }
        
        NSLog(@"%@ found",[sequenceNumber stringValue]);
        
        NSString *headerPath = [[NSBundle mainBundle]pathForResource:@"header" ofType:@"html"];
        NSString *header = [NSString stringWithContentsOfFile:headerPath encoding:NSUTF8StringEncoding error:NULL];
        
        NSString *footerPath = [[NSBundle mainBundle]pathForResource:@"footer" ofType:@"html"];
        NSString *footer = [NSString stringWithContentsOfFile:footerPath encoding:NSUTF8StringEncoding error:NULL];
        
        NSString *content = [unitContent stringValue];
                
        content = [self processContent:content];
        
        NSString *html = [NSString stringWithFormat:@"%@%@%@",header,content,footer];
        
        NSLog(@"%@",html);
        
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
        
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:/*[NSNumber numberWithFloat:1.2], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:contentView.frame.size], DTMaxImageSize,*/@"Times New Roman", DTDefaultFontFamily,  @"purple", DTDefaultLinkColor, @"red", DTDefaultLinkHighlightColor, /*callBackBlock, DTWillFlushBlockCallBack, */@"30",DTDefaultFirstLineHeadIndent,@"1.0",DTDefaultLineHeightMultiplier,nil];
        
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
        contentView.attributedString = string;
        [contentView scrollRectToVisible:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height) animated:NO];
        if ([self.section isEqualToString:@"0"]) {
            break;
        }
    }
}

- (NSString *)processContent:(NSString *)content
{
    
    NSString *regexToReplace = @"<(h\\d) id=\"(.*)\">(.*)</\\1>"; //id=\"(.*)\">(.*)<\\/h\1>";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexToReplace
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    content = [regex stringByReplacingMatchesInString:content
                                              options:0
                                                range:NSMakeRange(0, content.length)
                                         withTemplate:[NSString stringWithFormat:@"<div class='$1' id='$2'>$3</div>"]];
    
    content = [self processImage:content];
    content = [self processWordImage:content];
    content = [self processTable:content];
    return content;
}

- (NSString *)processImage:(NSString *)content
{
    NSString *regexToReplace = @"<IMG id=\"(.*)\"\\s/>";
    NSError *error = NULL;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexToReplace
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    
    int length = content.length;
    NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, length)];
    
    for (NSTextCheckingResult *result in matches) {
        NSRange range = [result rangeAtIndex:0];
        NSRange range1 = [result rangeAtIndex:1];
        NSString *imgStr = [content substringWithRange:range1];
        if (![[content substringWithRange:range] hasPrefix:@"<IMG"]) {
            continue;
        }
        /*NSString *xmlPath = [[NSBundle mainBundle]pathForResource:imgStr ofType:@"xml"];
        
        NSLog(@"range:%@",[content substringWithRange:range]);
        
       
        if (!xmlPath) {
            NSString *replacement = [NSString stringWithFormat:@"<img id='%@' src='%@.jpg'/>",imgStr,imgStr];
            if ([imgStr hasPrefix:@"BZ"]) {
                replacement = [NSString stringWithFormat:@"<img id='%@' src='%@.png' height='20px' width='20px'/>",imgStr,imgStr];
            }
            NSLog(@"%@",replacement);
            content = [content stringByReplacingCharactersInRange:range withString:replacement];
            content = [self processContent:content];
        }
        
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
        
        float ratio = (contentView.frame.size.width-80) / width;
        
        float het = height * ratio;
        */
         
        NSString *replacement = [NSString stringWithFormat:@"<img id='%@' src='%@.jpg' style='width:%f'/>",imgStr,imgStr,contentView.size.width-80];

        content = [content stringByReplacingCharactersInRange:range withString:replacement];
        content = [self processImage:content];
    }

    return content;
}

- (NSString *)processWordImage:(NSString *)content
{
    NSString *regexToReplace = @"<img src=\"BZ(.*)\" />";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexToReplace
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    content = [regex stringByReplacingMatchesInString:content
                                              options:0
                                                range:NSMakeRange(0, content.length)
                                         withTemplate:[NSString stringWithFormat:@"<img src='BZ$1' class='wordpng'/>"]];
    return content;
}
- (NSString *)processTable:(NSString *)content
{
    NSString *regexToReplace = @"<TABLE id=\"T(.*)\" />";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexToReplace
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    content = [regex stringByReplacingMatchesInString:content
                                              options:0
                                                range:NSMakeRange(0, content.length)
                                         withTemplate:[NSString stringWithFormat:@"<img src='T$1.jpg' style='width:%f' class='contentimgc'/>",contentView.frame.size.width-80]];
    return content;
}

@end
