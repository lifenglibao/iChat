//
//  CommonFunctions.h
//  MyWaters
//
//  Created by Ajay Bhardwaj on 10/2/15.
//  Copyright (c) 2015 iAppsAsia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CommonFunctions : NSObject

+ (MBProgressHUD *)showGlobalProgressHUDWithTitle:(NSString *)title;
+ (void)dismissGlobalHUD;


+(void)showAlertWithTitle:(NSString*)title msg:(NSString*)msg_ delegate:(id)delegt cancelTitle:(NSString*)cTitle;
+(void)showAlertDelegate:(id)delegt msg:(NSString*)msg_ title:(NSString*)title cancelTitle:(NSString*)cTitle otherTitle:(NSString*)titles;

+ (void) showActionSheet:(id)dele containerView:(UIView *) view title:(NSString*)sheetTitle msg:(NSString*)alertMessage cancel:(NSString *)cancelTitle tag:(NSInteger)tagValue destructive:(NSString *)destructiveButtonTitle otherButton:(NSString *)otherButtonTitles, ...;

+ (NSString *)getStringFromDate:(NSDate *)date;
+ (NSDate *)getDateFromString:(NSString *)date;
+ (NSDate *)getDateFromStringWithGMT:(NSString *)date;
+(NSString *) getAvailStr:(id) str;
@end
