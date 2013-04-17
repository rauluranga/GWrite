//
//  GWriteViewController.m
//  GWrite
//
//  Created by Raul Uranga on 4/5/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "GWriteViewController.h"
#import "SundownWrapper.h"
#import "DraggableUIImageView.h"
#import "RegexKitLite.h"

#define SPACE 8.0

@interface GWriteViewController () <UITextViewDelegate, DraggableUIImageViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet DraggableUIImageView *splitView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *accessoryView;
@property (assign, nonatomic) CGRect textViewFrame;
@property (assign, nonatomic) CGRect webViewFrame;
@property (strong, nonatomic) NSTimer *refresTimer;

@end

@implementation GWriteViewController

@synthesize draggableImageViewCenter = _draggableImageViewCenter;
@synthesize refresTimer = _refresTimer;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHiiden:) name:UIKeyboardWillHideNotification object:nil];
    //
    //Setup Inconsolata font
    [self.textView setFont:[UIFont fontWithName:@"Inconsolata" size:self.textView.font.pointSize]];
    
    //from http://subtlepatterns.com/
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"pattern"]];
    [self.splitView setBackgroundColor:backgroundColor];
    
    [self.splitView setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self updateWebView];
}

-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self setDraggableImageViewCenter:self.splitView.center];
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

-(void) updateUI {
    
    
    CGRect frame = self.textView.frame;
    CGFloat targetWidth = self.draggableImageViewCenter.x - self.splitView.frame.size.width/2 - SPACE;
    if (targetWidth < 1) {
        targetWidth = 1;
    }
    frame.size.width = targetWidth;
    [self.textView setFrame:frame];
    
    frame = self.webView.frame;
    frame.origin.x = self.draggableImageViewCenter.x + self.splitView.frame.size.width/2 + SPACE;
    
    CGFloat screenWidth = UIDeviceOrientationIsLandscape(self.interfaceOrientation) ? 1024 : 768;
    
    frame.size.width = screenWidth - frame.origin.x;
    [self.webView setFrame:frame];
}


-(void) updateWebView {
    
    NSString *rawText = self.textView.text;
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.grupow.gwrite.queue", NULL);
    dispatch_async(backgroundQueue, ^(void) {
        
        id html = [SundownWrapper convertMarkdownString:rawText];
        
        NSLog(@"%@", html);
        
        NSString *sampleHTML = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><link rel='stylesheet' href='bootstrap.min.css' type='text/css' /><link rel='stylesheet' href='main.css' type='text/css' /></head><body>%@</body></html>", html];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.webView loadHTMLString:sampleHTML baseURL:baseURL];
        });
    });
    
}

-(void) resizeViewFromKeyboardFrame:(CGRect)keyboardFrame view:(UIView *)theView {
    
    CGRect frame =  theView.frame;
    
    float offset = keyboardFrame.size.height;
    //[UIDevice currentDevice].orientation
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        offset = keyboardFrame.size.width;
    }
    
    frame.size.height -= offset;
    [theView setFrame:frame];

}

//from http://nachbaur.com/blog/basics-positioning-uiviews
//http://blog.initlabs.com/post/7115375694/how-to-detect-ios-device-orientation-on-load
//http://stackoverflow.com/questions/2315177/from-willanimaterotationtointerfaceorientation-how-can-i-get-the-size-the-view-w
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self setDraggableImageViewCenter:self.splitView.center];
}

#pragma mark -
#pragma mark UIKeyboard Notifications

- (void)keyboardShown:(NSNotification *)note {
    
    CGRect keyboardFrame;
    [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
   
    self.textViewFrame = self.textView.frame;
    self.webViewFrame = self.webView.frame;
    
    [self resizeViewFromKeyboardFrame:keyboardFrame view:self.textView];
    [self resizeViewFromKeyboardFrame:keyboardFrame view:self.webView];
}

- (void)keyboardHiiden:(NSNotification *)note {
    
    [self.textView setFrame:self.textViewFrame];
    [self.webView setFrame:self.webViewFrame];
}

#pragma mark -
#pragma mark UITextFieldDelegate implementation

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    [self.refresTimer invalidate];
    self.refresTimer = nil;
    self.refresTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateWebView) userInfo:nil repeats:NO];
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self.accessoryView setHidden:NO];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self.textView setInputAccessoryView:self.accessoryView];
    return YES;
}

#pragma mark -
#pragma mark DraggableUIImageViewDelegate implementation

-(void) setDraggableImageViewCenter:(CGPoint)point {
    
    _draggableImageViewCenter = point;
    [self updateUI];
}

#pragma mark -
#pragma mark Toolbar AccessoryView handlers

//@see http://blog.carbonfive.com/2012/03/12/customizing-the-ios-keyboard/
//@see http://www.theappcodeblog.com/2011/02/27/keyboard-tutorial-part-3-add-a-toolbar-to-the-keyboard/


//@see http://rubular.com/
//@see https://gist.github.com/jbroadway/2836900
//    '/(#+)(.*)/e' => 'self::header (\'\\1\', \'\\2\')',       // headers
//    '/\[([^\[]+)\]\(([^\)]+)\)/' => '<a href=\'\2\'>\1</a>',  // links
//    '/(\*\*|__)(.*?)\1/' => '<strong>\2</strong>',            // bold
//    '/(\*|_)(.*?)\1/' => '<em>\2</em>',                       // emphasis
//    '/\~\~(.*?)\~\~/' => '<del>\1</del>',                     // del
//    '/\:\"(.*?)\"\:/' => '<q>\1</q>',                         // quote
//    '/\n\*(.*)/e' => 'self::ul_list (\'\\1\')',               // ul lists
//    '/\n[0-9]+\.(.*)/e' => 'self::ol_list (\'\\1\')',         // ol lists
//    '/\n&gt;(.*)/e' => 'self::blockquote (\'\\1\')',          // blockquotes
//    '/\n([^\n]+)\n/e' => 'self::para (\'\\1\')',              // add paragraphs
//    '/<\/ul><ul>/' => '',                                     // fix extra ul
//    '/<\/ol><ol>/' => '',                                     // fix extra ol
//    '/<\/blockquote><blockquote>/' => "\n"                    // fix extra blockquote

- (IBAction)toggleStrong:(id)sender {
    UITextRange *selectedTextRange = self.textView.selectedTextRange;
    NSString *selectedText = [self.textView textInRange:selectedTextRange];
    
    if (selectedTextRange == nil) {
    
        //no selection or insertion point
    
    } else if (selectedTextRange.empty) {
      
        //inserting text at an insertion point
        //...
        [self.textView replaceRange:selectedTextRange withText:@"****"];
        
        [self.textView setSelectedRange:NSMakeRange(self.textView.selectedRange.location - 2, 0)];
    
    } else {
        
        //updated a selected range
        //...
        
        NSString *regEx = @"(\\*\\*|__)(.*?)\\1";
        NSUInteger numOfMatches = [[selectedText componentsMatchedByRegex:regEx] count];
        NSLog(@"numOfMatches: %d", numOfMatches);
        
        if (numOfMatches > 0) {
            
            NSString *replacedString;
            NSString *replaceWithString = @"$2";
            replacedString = [selectedText stringByReplacingOccurrencesOfRegex:regEx withString:replaceWithString];
            
            [self.textView replaceRange:selectedTextRange withText:replacedString];
            
        } else {
            
            [self.textView replaceRange:selectedTextRange withText:[NSString stringWithFormat:@"**%@**", [self.textView textInRange:selectedTextRange]]];
            
        }
        
        // THIS ALSO WORKS
//
//        NSString *regEx = @"\\*\\*(.*?)\\*\\*";        
//        NSUInteger numOfMatches = [[selectedText componentsMatchedByRegex:regEx] count];
//        
//        NSLog(@"numOfMatches: %d", numOfMatches);
//        
//        // if we found any matches for strong tokens
//        if ( numOfMatches > 0) {
//            
//            NSString *replacedString;
//            //*/
//            //remove strong markup
//            NSString *replaceWithString = [@"$1" stringByReplacingOccurrencesOfString:@"**" withString:@""]; // THIS STEP IS REMOVED IN ABOVE CODE
//            replacedString = [selectedText stringByReplacingOccurrencesOfRegex:regEx withString:replaceWithString];
//            /*/
//            replacedString = [selectedText stringByReplacingOccurrencesOfRegex:regEx
//                                                                    usingBlock:^NSString *(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop) {
//                                                                        
//                                                                              return [capturedStrings[1] stringByReplacingOccurrencesOfString:@"**" withString:@""];
//                                                                          }];
//            //*/
//            NSLog(@"replacedString: %@", replacedString);
//            
//            [self.textView replaceRange:selectedTextRange withText:replacedString];
//            
//        } else {
//            
//            [self.textView replaceRange:selectedTextRange withText:[NSString stringWithFormat:@"**%@**", [self.textView textInRange:selectedTextRange]]];
//        }
        
    }
}

- (IBAction)toggleEmphasis:(id)sender {
    
    UITextRange *selectedTextRange = self.textView.selectedTextRange;
    NSString *selectedText = [self.textView textInRange:selectedTextRange];
    
    if (selectedTextRange.empty) {
        
        //inserting text at an insertion point
        [self.textView replaceRange:selectedTextRange withText:@"*"];
        
    } else {
        
        //updated a selected range
        
        NSString *regEx = @"(\\*|_)(.*?)\\1";
        NSUInteger numOfMatches = [[selectedText componentsMatchedByRegex:regEx] count];
        
        if (numOfMatches > 0) {
            
            NSString *replacedString;
            NSString *replaceWithString = @"$2";
            replacedString = [selectedText stringByReplacingOccurrencesOfRegex:regEx withString:replaceWithString];
            
            [self.textView replaceRange:selectedTextRange withText:replacedString];
            
        } else {
            
            [self.textView replaceRange:selectedTextRange withText:[NSString stringWithFormat:@"*%@*", selectedText]];
            
        }
        
    }
}

- (IBAction)toggleCode:(id)sender {
    
    UITextRange *selectedTextRange = self.textView.selectedTextRange;
    NSString *selectedText = [self.textView textInRange:selectedTextRange];
    
    if (selectedTextRange == nil) {
        
        //no selection or insertion point
        
    } else if (selectedTextRange.empty) {
        
        //inserting text at an insertion point
        //...
        [self.textView replaceRange:selectedTextRange withText:@"`"];
        
    } else {
        
        //updated a selected range
        //...
        
        NSString *regEx = @"(\\`)(.*?)\\1";
        NSUInteger numOfMatches = [[selectedText componentsMatchedByRegex:regEx] count];
        NSLog(@"numOfMatches: %d", numOfMatches);
        
        if (numOfMatches > 0) {
            
            NSString *replacedString;
            NSString *replaceWithString = @"$2";
            replacedString = [selectedText stringByReplacingOccurrencesOfRegex:regEx withString:replaceWithString];
            
            [self.textView replaceRange:selectedTextRange withText:replacedString];
            
        } else {
            
            [self.textView replaceRange:selectedTextRange withText:[NSString stringWithFormat:@"`%@`", selectedText]];
            
        }
    }
}

- (IBAction)toggleHeader:(id)sender {
    
    UITextRange *selectedTextRange = self.textView.selectedTextRange;
    NSString *selectedText = [self.textView textInRange:selectedTextRange];
    
    if (selectedTextRange == nil) {
        
        //no selection or insertion point
        
    } else if (selectedTextRange.empty) {
        
        //inserting text at an insertion point
        //...
        [self.textView replaceRange:selectedTextRange withText:@"#"];
        
    } else {
        
        //updated a selected range
        //...
        
        NSString *regEx = @"(\\#)(.*?)\\1";
        NSUInteger numOfMatches = [[selectedText componentsMatchedByRegex:regEx] count];
        NSLog(@"numOfMatches: %d", numOfMatches);
        
        if (numOfMatches > 0) {
            
            NSString *replacedString;
            NSString *replaceWithString = @"$2";
            replacedString = [selectedText stringByReplacingOccurrencesOfRegex:regEx withString:replaceWithString];
            
            [self.textView replaceRange:selectedTextRange withText:replacedString];
            
        } else {
            
            [self.textView replaceRange:selectedTextRange withText:[NSString stringWithFormat:@"#%@#", selectedText]];
            
        }
    }
    
}

@end

//-(void) viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    id html = [SundownWrapper convertMarkdownString:self.textView.text];
//    //NSLog(@"html: %@", html);
//    
//    NSString *path = [[NSBundle mainBundle] bundlePath];
//    NSURL *baseURL = [NSURL fileURLWithPath:path];
//    
//    //NSString *sampleHTML = @"<!DOCTYPE html><html><head><link rel=\"stylesheet\" href=\"bootstrap.min.css\" type=\"text/css\" /><link rel=\"stylesheet\" href=\"main.css\" type=\"text/css\" /></head><body><h1>My First Heading</h1><p>My first paragraph.</p></body></html>";
//     
//    NSString *sampleHTML = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><link rel='stylesheet' href='bootstrap.min.css' type='text/css' /><link rel='stylesheet' href='main.css' type='text/css' /></head><body>%@</body></html>", html];
//     
//    [self.webView loadHTMLString:sampleHTML baseURL:baseURL];
//    [self refresh];
//}
//- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    
//}
//
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    
//    
//        // we grab the screen frame first off; these are always
//        // in portrait mode
//        CGRect bounds = [[UIScreen mainScreen] applicationFrame];
//        CGSize size = bounds.size;
//    
//        NSLog(@"bounds.size: w:%f h:%f", size.width, size.height);
//    
//        // let's figure out if width/height must be swapped
//        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
//            // we're going to landscape, which means we gotta swap them
//            size.width = bounds.size.height;
//            size.height = bounds.size.width;
//        }
//        // size is now the width and height that we will have after the rotation
//        NSLog(@"size: w:%f h:%f", size.width, size.height);
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    
//}
