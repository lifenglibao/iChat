//
//  AuxilaryService.m
//  NParks
//
//  Created by Raja Saravanan on 1/29/12.
//  Copyright (c) 2012 Shownearby. All rights reserved.
//


#import "AuxilaryService.h"
#import "iChat-Swift.h"

@interface AuxilaryService()

@property (nonatomic,strong) AppDelegate *appDelegate;

@end

@implementation AuxilaryService

- (id)init
{
    self = [super init];
    
    if (self) {
        NSString *dbFilePath = [self getDataBasePath];
        self.queue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
    }
    return self;
}


+(AuxilaryService*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (void) test:(NSString*)sql{
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            [db executeUpdate:sql];
        }
    }];
}
- (NSString*)getDataBasePath{
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return _appDelegate.getdestinationPath;
}
@end
