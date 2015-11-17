//
//  NumberedTextView.m
//  GWrite
//
//  Created by Raul Uranga on 4/10/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "NumberedTextView.h"

@interface NumberedTextView () <UITextViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *internalScrollView;
@property (strong, nonatomic) UITextView *internalTextView;

@end


#define TXT_VIEW_INSETS 0.0 // The default insets for a UITextView is 8.0 on all sides

@implementation NumberedTextView

@synthesize lineNumbers;

- (void)setup
{
    [self setContentMode:UIViewContentModeRedraw];
    
    self.internalScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self.internalScrollView       setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.internalScrollView        setBackgroundColor:[UIColor clearColor]];
    [self.internalScrollView          setClipsToBounds:YES];
    [self.internalScrollView           setScrollsToTop:YES];
    [self.internalScrollView            setContentSize:self.bounds.size];
    [self.internalScrollView            setContentMode:UIViewContentModeLeft];
    [self.internalScrollView               setDelegate:self];
    [self.internalScrollView                setBounces:YES];
    
    self.internalTextView = [[UITextView alloc] initWithFrame:self.bounds];
    [self.internalTextView  setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.internalTextView      setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.internalTextView       setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.internalTextView        setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.internalTextView         setBackgroundColor:[UIColor clearColor]];
    [self.internalTextView           setClipsToBounds:YES];
    [self.internalTextView            setScrollsToTop:NO];
    [self.internalTextView             setContentMode:UIViewContentModeLeft];
    [self.internalTextView                setDelegate:self];
    [self.internalTextView                 setBounces:YES];
    
    [self.internalScrollView addSubview:self.internalTextView];
    [self addSubview:self.internalScrollView];
    
    self.lineNumbers = YES;
    //self.internalTextView.text = @"Lorem ipsum dolor sit amet,\n consectetur adipiscing elit.\nCras vulputate urna id dui \npellentesque interdum.\n Morbi convallis eleifend dolor non ultricies. \nInteger vel orci in diam vulputate adipiscing. \nAenean commodo, felis \nelementum posuere blandit, t\nurpis nisl cursus justo, eu rhoncus tortor mi sed eros.\n Nam pulvinar \nsapien a felis blandit interdum.\n Quisque velit velit, rutrum et \nblandit nec, sagittis eu mi. \nAliquam vitae diam in dolor adipiscing placerat. Maecenas fermentum, est tincidunt \nblandit sollicitudin, libero mi hendrerit nibh, id tempus leo risus dictum lorem.\n Nullam quis quam id sem porta dictum \nid vel quam.\n Suspendisse \nnec dolor justo. Vivamus a \nlobortis felis.\n Class aptent taciti sociosqu ad \nlitora torquent per conubia nostra, \nper inceptos himenaeos.";
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (self.lineNumbers) {
        [[self.internalTextView textColor] set];
        CGFloat xOrigin, yOrigin, width/*, height*/;
        uint numberOfLines = (self.internalTextView.contentSize.height + self.internalScrollView.contentSize.height) / self.internalTextView.font.lineHeight;
        for (uint x = 0; x < numberOfLines; ++x) {
            NSString *lineNum = [NSString stringWithFormat:@"%d:", x];
            
            xOrigin = CGRectGetMinX(self.bounds);
            
            yOrigin = ((self.internalTextView.font.pointSize + abs(self.internalTextView.font.descender)) * x) + TXT_VIEW_INSETS - self.internalScrollView.contentOffset.y;
            
            width = [lineNum sizeWithFont:self.internalTextView.font].width;
            //            height = self.internalTextView.font.lineHeight;
            
            [lineNum drawAtPoint:CGPointMake(xOrigin, yOrigin) withFont:self.internalTextView.font];
        }
        
        CGRect tvFrame = [self.internalTextView frame];
        tvFrame.size.width = CGRectGetWidth(self.internalScrollView.bounds) - width;
        tvFrame.size.height = MAX(self.internalTextView.contentSize.height, CGRectGetHeight(self.internalScrollView.bounds));
        tvFrame.origin.x = width;
        [self.internalTextView setFrame:tvFrame];
        tvFrame.size.height -= TXT_VIEW_INSETS; // This fixed a weird content size problem that I've forgotten the specifics of.
        [self.internalScrollView setContentSize:tvFrame.size];
    }
}

#pragma mark - UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self setNeedsDisplay];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self setNeedsDisplay];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self setNeedsDisplay];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setNeedsDisplay];
}

@end
