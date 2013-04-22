//
//  DocumentsContentListVC.m
//  GWrite
//
//  Created by Raul on 4/22/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "MarkdownContentVC.h"

@interface MarkdownContentVC ()

@end

@implementation MarkdownContentVC

@synthesize delegate = _delegate;

-(NSString *) getNextFileName {
    return [NSString stringWithFormat:@"%@.markdown", [NSDate date]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GWFile *file = [self getGWFileForRow:indexPath.row];
    NSLog(@"file name: %@", file.fileName);
    NSLog(@"isDirectory: %@", (file.isDirectory ? @"YES" : @"NO"));
    
    [self.delegate displayContentsOfFile:file.contents];
    
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //NSString *cellText = cell.textLabel.text;
}

@end
