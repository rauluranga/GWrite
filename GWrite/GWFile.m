//
//  GWFile.m
//  NSFileManagerTest
//
//  Created by Raul on 4/18/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "GWFile.h"

@implementation GWFile

@synthesize path;

+ (id)fileFromDocuments:(NSString *)fileName {
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * filePath = [rootPath stringByAppendingPathComponent:fileName];
    return [[self alloc] initWithPath:filePath];
}

+ (id)fileWithPath:(NSString *)filePath {
    return [[self alloc] initWithPath:filePath];
}

- (id)initWithPath:(NSString *)filePath {
    self = [super init];
    if (self != nil) {
        self.path = filePath;
    }
    return self;

}

- (BOOL)writeData:(NSData *)data error:(NSError **)error {
     return [data writeToFile:path options:NSDataWritingAtomic error:error];
}

- (BOOL)delete:(NSError **)error {
    
    if ([self exists]) {
        
        NSFileManager * fileManager = [NSFileManager new];
        return [fileManager removeItemAtPath:path error:error];
        
    }
    
    return NO;
}

- (BOOL)createFile {
        
    if (![self exists]) {
        NSFileManager * fileManager = [NSFileManager new];
        return [fileManager createFileAtPath:self.path contents:nil attributes:nil];
    }
    
    return NO;
}

- (BOOL)createDirectory:(NSError **)error {
    
    if (![self exists]) {
        NSFileManager * fileManager = [NSFileManager new];
        return [fileManager createDirectoryAtPath:self.path withIntermediateDirectories:NO attributes:nil error:error];
    }
    
    return NO;
}

- (NSString *)fileName {
    return [[self.path lastPathComponent] stringByDeletingPathExtension];
}

//TODO: handle error
- (NSString *)contents {
    
    NSError *error = nil;
    NSString * contents = [NSString stringWithContentsOfFile:self.path
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    return contents;
    
}

- (BOOL)exists {
    NSFileManager * fileManager = [NSFileManager new];
    return  [fileManager fileExistsAtPath:self.path];
}

- (NSInteger)size {
    NSFileManager * fileManager = [NSFileManager new];
    NSError *error = nil;
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:self.path error: &error];
    return [attrs fileSize];
}

- (NSDate *)lastModificationDate {
    NSFileManager * fileManager = [NSFileManager new];
    NSError *error = nil;
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:self.path error: &error];
    return [attrs fileModificationDate];
}

- (BOOL)isDirectory {
    BOOL isDir = NO;
    NSFileManager * fileManager = [NSFileManager new];
    [fileManager fileExistsAtPath:self.path isDirectory:(&isDir)];
    return isDir;
}

@end
