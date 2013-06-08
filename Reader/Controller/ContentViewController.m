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
    foundContent = NO;
    
    [self loadData:self.articleId];

    [self renderContextLink];
}

- (void)loadData:(NSString *) aId
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"book" ofType:@"xml"];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding  error:NULL];
    if (!doc) {
        return;
    }
    NSString *sectionTag = @"";
    if ([self.section isEqualToString:@"0"]) {
        sectionTag = @"front_of_book";
    }else if ([self.section isEqualToString:@"1"]) {
        sectionTag = @"body_of_book";
    }else {
        sectionTag = @"back_of_book";
    }
    NSString *xpathExpression = [NSString stringWithFormat:@"//book/%@/Article",sectionTag];
    
    NSLog(@"xpathExpression:%@",xpathExpression);
    
    NSArray *items = [doc nodesForXPath:xpathExpression error:NULL];
    for (int i=0; i < items.count ; i++) {
        GDataXMLElement *item = [items objectAtIndex:i];
        GDataXMLNode *sequenceNumber = [item childAtIndex:0] ;
        NSString *txt = [sequenceNumber stringValue];
        if (![txt isEqualToString:aId]) {
            continue;
        }
        
        foundContent = YES;
        
        current = [item copy];
        
        if (i > 1) {
            previous = [items objectAtIndex:(i-1)];
        }
       
        if (i < items.count - 1) {
            next = [items objectAtIndex:(items.count - 1)];
        }
                
        NSArray *nodes = [item nodesForXPath:@"./Unit_content" error:NULL];
        if (!nodes || [nodes count] < 1) {
            break;
        }
        GDataXMLNode *unitContent = [nodes objectAtIndex:0];
        NSLog(@"%@ found",[sequenceNumber stringValue]);

        NSString *headerPath = [[NSBundle mainBundle]pathForResource:@"header" ofType:@"html"];
        NSString *header = [NSString stringWithContentsOfFile:headerPath encoding:NSUTF8StringEncoding error:NULL];
        
        NSString *footerPath = [[NSBundle mainBundle]pathForResource:@"footer" ofType:@"html"];
        NSString *footer = [NSString stringWithContentsOfFile:footerPath encoding:NSUTF8StringEncoding error:NULL];
        
        NSString *content = [unitContent stringValue];
                
        content = [self processContent:content];
        
        NSString *html = [NSString stringWithFormat:@"%@%@%@",header,content,footer];
                
        NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
       /* void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
            
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
        };*/
        
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:/*[NSNumber numberWithFloat:1.2], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:contentView.frame.size], DTMaxImageSize,*/@"Times New Roman", DTDefaultFontFamily,  @"purple", DTDefaultLinkColor, @"red", DTDefaultLinkHighlightColor, /*callBackBlock, DTWillFlushBlockCallBack, */@"30",DTDefaultFirstLineHeadIndent,@"1.0",DTDefaultLineHeightMultiplier,nil];
        
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
        contentView.attributedString = string;
        if (contentView.contentSize.height >contentView.frame.size.height) {
            [contentView scrollToAnchorNamed:[NSString stringWithFormat:@"CHP%@",self.articleId] animated:NO];
        }
        if ([self.section isEqualToString:@"0"]) {
            break;
        }
    }
    [self shortenArticleId:aId];
}

- (void)shortenArticleId:(NSString *)aId
{
    if (aId.length < 3 || foundContent) {
        foundContent = NO;
        return;
    }
    NSLog(@"before:%@",aId);
    aId = [aId substringToIndex:(aId.length-2)];
    NSLog(@"after:%@",aId);
    [self loadData:aId];
}

- (void)renderContextLink
{
    if (!topLink) {
        topLink = [[UILabel alloc]initWithFrame:CGRectMake(0, -60, contentView.frame.size.width, 60)];
        topLink.backgroundColor = [UIColor lightGrayColor];
        topLink.textAlignment = NSTextAlignmentCenter;
        topLink.font = [UIFont systemFontOfSize:25];
        [contentView addSubview:topLink];
    }
    if (!bottomLink) {
        bottomLink = [[UILabel alloc]initWithFrame:CGRectMake(0, contentView.frame.size.height+ 60, contentView.frame.size.width, 60)];
        bottomLink.backgroundColor = [UIColor lightGrayColor];
        bottomLink.textAlignment = NSTextAlignmentCenter;
        bottomLink.font = [UIFont systemFontOfSize:25];
        [contentView addSubview:bottomLink];
    }
    topLink.text = @"top";
    bottomLink.text = @"bottom";
}

- (NSString *)processContent:(NSString *)content
{
    
    NSString *regexToReplace = @"<(h\\d+) id=\"(.*)\">(.*)</\\1>"; //id=\"(.*)\">(.*)<\\/h\1>";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexToReplace
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    content = [regex stringByReplacingMatchesInString:content
                                              options:0
                                                range:NSMakeRange(0, content.length)
                                         withTemplate:[NSString stringWithFormat:@"<a name='$2'><div class='$1' id='$2' name='$2'>$3</div></a>"]];
    
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
        NSString *xmlPath = [[NSBundle mainBundle]pathForResource:imgStr ofType:@"xml"];
        
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
        
         
        NSString *replacement = [NSString stringWithFormat:@"<img id='%@' src='%@.jpg' style='width:%fpx;height:%fpx;'/>",imgStr,imgStr,contentView.size.width-80,het];
    
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
