//
//  MasterViewController.h
//  NSFileManagerTest
//
//  Created by Raul on 4/17/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWFile.h"

@interface DirectoryContentManagerVC : UITableViewController {
    
}
@property (nonatomic, strong) NSString *rootPath;

-(GWFile *) getGWFileForRow:(NSUInteger) row;

@end
