//
//  DocumentsContentListVC.m
//  GWrite
//
//  Created by Raul on 4/22/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "MarkdownContentVC.h"
#import "GWFile.h"

@interface MarkdownContentVC ()

@end

@implementation MarkdownContentVC

-(NSString *) getNextFileName {
    return [NSString stringWithFormat:@"%@.markdown", [NSDate date]];
}

@end
