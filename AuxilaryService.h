//
//  AuxilaryService.h
//  NParks
//
//  Created by Raja Saravanan on 1/29/12.
//  Copyright (c) 2012 Shownearby. All rights reserved.
//

// --- animation helpers


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
@interface AuxilaryService : FMDatabase

@property (nonatomic,strong) FMDatabaseQueue* queue;

+(AuxilaryService*)sharedInstance;
- (void) test:(NSString*)sql;
@end
