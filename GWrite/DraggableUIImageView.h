//
//  DraggableUIImage.h
//  GWrite
//
//  Created by Raul Uranga on 4/8/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DraggableUIImageViewDelegate
    @property (nonatomic, assign) CGPoint draggableImageViewCenter;
@end

@interface DraggableUIImageView : UIImageView
{
    
}

@property(nonatomic, weak) id <DraggableUIImageViewDelegate> delegate;

@end

