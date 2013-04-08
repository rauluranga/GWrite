//
//  DraggableUIImage.m
//  GWrite
//
//  Created by Raul Uranga on 4/8/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "DraggableUIImageView.h"

@interface DraggableUIImageView ()
{
    CGPoint currentPoint;
}
@end

@implementation DraggableUIImageView

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // When a touch starts, get the current location in the view
    currentPoint = [[touches anyObject] locationInView:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    NSLog(@"touchesBegan");
    // Get active location upon move
    CGPoint activePoint = [[touches anyObject] locationInView:self];
    
    // Determine new point based on where the touch is now located
//    CGPoint newPoint = CGPointMake(self.center.x + (activePoint.x - currentPoint.x),
//                                   self.center.y + (activePoint.y - currentPoint.y));
    
    CGPoint newPoint = CGPointMake(self.center.x + (activePoint.x - currentPoint.x),
                                   self.center.y);
    
    //--------------------------------------------------------
    // Make sure we stay within the bounds of the parent view
    //--------------------------------------------------------
    float midPointX = CGRectGetMidX(self.bounds);
    // If too far right...
    if (newPoint.x > self.superview.bounds.size.width  - midPointX)
        newPoint.x = self.superview.bounds.size.width - midPointX;
    else if (newPoint.x < midPointX)  // If too far left...
        newPoint.x = midPointX;
    
    float midPointY = CGRectGetMidY(self.bounds);
    // If too far down...
    if (newPoint.y > self.superview.bounds.size.height  - midPointY)
        newPoint.y = self.superview.bounds.size.height - midPointY;
    else if (newPoint.y < midPointY)  // If too far up...
        newPoint.y = midPointY;
    
    // Set new center location
    self.center = newPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - Initialization

- (void)setup
{
    // do initialization here
    self.userInteractionEnabled = YES;
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

@end
