//
//  MasterViewController.m
//  NSFileManagerTest
//
//  Created by Raul on 4/17/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "DirectoryContentManagerVC.h"
#import "UIBAlertView.h"

#define ACTIONSHEET_TITLE @"Action Sheet Demo"
#define ACTIONSHEET_FOLDER_TITLE @"Create Folder"
#define ACTIONSHEET_FILE_TITLE @"Create File"
#define ACTIONSHEET_CANCEL_TITLE @"Cancel"

@interface DirectoryContentManagerVC () <UIActionSheetDelegate> {
    
}

@property (nonatomic, strong) NSMutableArray *folderContentList;


@end

@implementation DirectoryContentManagerVC

@synthesize rootPath = _rootPath;

-(NSString *) rootPath {
    if (!_rootPath) {
        _rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return _rootPath;
}

-(GWFile *) getGWFileForRow:(NSUInteger) row {
    return (GWFile *)self.folderContentList[row];
}

-(NSArray *) folderContentList {
    if (!_folderContentList) {
        
        NSFileManager *fileManager = [NSFileManager new];
        NSArray *list = [fileManager contentsOfDirectoryAtPath:self.rootPath error:nil];
        _folderContentList = [NSMutableArray array];
        
        for (NSString *fileName in list) {
            NSString *path = [self.rootPath stringByAppendingPathComponent:fileName];
            GWFile *file = [GWFile fileWithPath:path];
            [_folderContentList addObject:file];
        }
    }
    return  _folderContentList;
}

-(NSString *) getNextFolderName {
    return [NSString stringWithFormat:@"%@", [NSDate date]];
}

-(NSString *) getNextFileName {
    return [NSString stringWithFormat:@"%@", [NSDate date]];
}

- (void)viewDidLoad
{    
    [super viewDidLoad];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self setTitle:[[self.rootPath lastPathComponent] stringByDeletingPathExtension]];
}

- (void)insertNewObject:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:ACTIONSHEET_TITLE
                                  delegate:self
                                  cancelButtonTitle:ACTIONSHEET_CANCEL_TITLE
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:ACTIONSHEET_FOLDER_TITLE, ACTIONSHEET_FILE_TITLE, nil];
    
    [actionSheet showInView:self.view];
}

-(void) createNewFileWithFileName:(NSString *)fileName {
    
    NSString *filePath = [self.rootPath stringByAppendingPathComponent:fileName];

    GWFile *file = [GWFile fileWithPath:filePath];
    
    if ([file createFile]) {
        [self.folderContentList addObject:file];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.folderContentList.count - 1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        NSLog(@"Couldn't create file");
    }
}

-(void) createNewFolderWithFileName:(NSString *)fileName {   
    
    NSString *filePath = [self.rootPath stringByAppendingPathComponent:fileName];
   
    GWFile *file = [GWFile fileWithPath:filePath];
    
    NSError *error = nil;
    
    if ([file createDirectory:&error]) {
        [self.folderContentList addObject:file];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.folderContentList.count - 1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else {
        NSLog(@"Couldn't create Folder");
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    GWFile *file = [self getGWFileForRow:indexPath.row];
    
    if ([[segue identifier] isEqualToString:@"showDirectoryContents:"]) {
        if ([[segue destinationViewController] respondsToSelector:@selector(setRootPath:)]) {
            [[segue destinationViewController] setRootPath:file.path];
        }
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate implementation

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    /*/
    UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"" message:@"Choose file name" cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alert.activeAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
        
        if (didCancel) {
            NSLog(@"User cancelled");
            return;
        }
        
        switch (selectedIndex) {
            case 1:
                {
                    NSLog(@"1 selected");
                    
                    NSString *fileName = [alert.activeAlert textFieldAtIndex:0].text;
                    
                    NSLog(@"FileName: %@ ", fileName);
                    
                    if ([buttonTitle isEqualToString:ACTIONSHEET_FOLDER_TITLE]) {
                        [self createNewFolderWithFileName:fileName];
                    }
                    if ([buttonTitle isEqualToString:ACTIONSHEET_FILE_TITLE]) {
                        [self createNewFileWithFileName:fileName];
                    }
                }
                break;
            default:
                break;
        }
    }];
    
    /*/
    if ([buttonTitle isEqualToString:ACTIONSHEET_FOLDER_TITLE]) {
        [self createNewFolderWithFileName:[self getNextFolderName]];
    }
    if ([buttonTitle isEqualToString:ACTIONSHEET_FILE_TITLE]) {
        [self createNewFileWithFileName:[self getNextFileName]];
    }
    //*/
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.folderContentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GWFile *file = [self getGWFileForRow:indexPath.row];
    
    NSString *cellIdentifier = (file.isDirectory) ? @"Cell" : @"FileCell";
    NSString *imageName = (file.isDirectory) ? @"folder.png" : @"markdown.png";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.textLabel.text = [file fileName];
    cell.detailTextLabel.text = [file.lastModificationDate description];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        GWFile *file = [self getGWFileForRow:indexPath.row];
        
        NSError *error = nil;
        BOOL success = [file delete:&error];
        
        if (success) {
            [self.folderContentList removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
    
}

@end
