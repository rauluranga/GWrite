//
//  GWFile.h
//  NSFileManagerTest
//
//  Created by Raul on 4/18/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GWFile : NSObject {
    
}

@property (nonatomic, strong) NSString *path;

+ (id)fileFromDocuments:(NSString *)fileName;
+ (id)fileWithPath:(NSString *)filePath;
- (id)initWithPath:(NSString *)filePath;
- (BOOL)writeData:(NSData *)data error:(NSError **)error;
- (BOOL)delete:(NSError **)error;
- (BOOL)createFile;
- (BOOL)createDirectory:(NSError **)error;
- (NSString *)fileName;
- (NSString *)contents;
- (BOOL)exists;
- (NSInteger)size;
- (NSDate *)lastModificationDate;
- (BOOL)isDirectory;

@end
