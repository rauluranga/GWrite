//
//  NoteView.m
//  GWrite
//
//  Created by Raul Uranga on 4/10/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "NoteView.h"

@implementation NoteView

//@see http://stackoverflow.com/questions/5375350/uitextview-ruled-line-background-but-wrong-line-height

- (void)setup
{
    self.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.6f alpha:1.0f];
    self.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:19];
    self.contentMode = UIViewContentModeRedraw;}

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
    
    //Get the current drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    //Set the line color and width
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    //Start a new Path
    CGContextBeginPath(context);
    
    //Find the number of lines in our textView + add a bit more height to draw lines in the empty part of the view
    NSUInteger numberOfLines = (self.contentSize.height + self.bounds.size.height) / self.font.leading;
    
    //Set the line offset from the baseline. (I'm sure there's a concrete way to calculate this.)
    CGFloat baselineOffset = 6.0f;
    
    //iterate over numberOfLines and draw each line
    for (int x = 0; x < numberOfLines; x++) {
        //0.5f offset lines up line with pixel boundary
        CGContextMoveToPoint(context, self.bounds.origin.x, self.font.leading*x + 0.5f + baselineOffset);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.font.leading*x + 0.5f + baselineOffset);
    }
    
    //Close our Path and Stroke (draw) it
    CGContextClosePath(context);
    CGContextStrokePath(context);
}

@end
