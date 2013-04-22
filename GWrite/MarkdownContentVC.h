//
//  DocumentsContentListVC.h
//  GWrite
//
//  Created by Raul on 4/22/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "DirectoryContentManagerVC.h"
#import "GWriteViewController.h"

@interface MarkdownContentVC : DirectoryContentManagerVC {
    
}

@property(nonatomic, weak) GWriteViewController *delegate;
@end
