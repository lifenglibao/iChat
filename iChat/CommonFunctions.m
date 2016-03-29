//
//  CommonFunctions.m
//  MyWaters
//
//  Created by Ajay Bhardwaj on 10/2/15.
//  Copyright (c) 2015 iAppsAsia. All rights reserved.
//

#import "CommonFunctions.h"

@implementation CommonFunctions

static UIWindow *window;


//*************** Function To Show Global MBProgressView

+ (MBProgressHUD *)showGlobalProgressHUDWithTitle:(NSString *)title {
    
    window = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideAllHUDsForView:window animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = title;
    return hud;
}

//*************** Function To Hide Global MBProgressView

+ (void)dismissGlobalHUD {
    
    window = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:window animated:YES];
}


//*************** Function To Get App Version From Info Plist

+ (NSString *) getAppVersionNumber {
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleVersion"];
    
    return version;
}



//*************** Method For Converting Date String To NSDate

+ (NSString *)getStringFromDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm:ss"];
    
    NSString *resultStrig = [dateFormatter stringFromDate:date];
    
    return resultStrig;
}

+ (NSDate *)getDateFromString:(NSString *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm:ss"];
    
    NSDate *resultDate = [dateFormatter dateFromString:date];
    
    return resultDate;
}

+ (NSDate *)getDateFromStringWithGMT:(NSString *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
    [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm:ss"];
    
    NSDate *resultDate = [dateFormatter dateFromString:date];
    
    return resultDate;
}
//*************** Method For Checking Valid Email

+ (BOOL) NSStringIsValidEmail:(NSString *)checkString {
    
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL result = [emailTest evaluateWithObject:checkString];
    return result;
}



//*************** Common Method For AlertViews


#pragma mark Show Alert
+(void)showAlertWithTitle:(NSString*)title msg:(NSString*)msg_ delegate:(id)delegt cancelTitle:(NSString*)cTitle{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(msg_, @"") delegate:delegt cancelButtonTitle:cTitle otherButtonTitles:nil];
    [alert show];
}

+(void)showAlertDelegate:(id)delegt msg:(NSString*)msg_ title:(NSString*)title cancelTitle:(NSString*)cTitle otherTitle:(NSString*)titles{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(msg_, @"") delegate:delegt cancelButtonTitle:cTitle otherButtonTitles:titles,nil];
    [alert show];
}


//*************** Common Method For Action Sheet Options

+ (void) showActionSheet:(id)dele containerView:(UIView *) view title:(NSString*)sheetTitle msg:(NSString*)alertMessage cancel:(NSString *)cancelTitle tag:(NSInteger)tagValue destructive:(NSString *)destructiveButtonTitle otherButton:(NSString *)otherButtonTitles, ... {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:dele cancelButtonTitle:cancelTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, nil];
    actionSheet.tag = tagValue;
    
    int destructiveButtonIndex = 0;
    
    if (otherButtonTitles != nil) {
        id eachObject;
        va_list argumentList;
        if (otherButtonTitles) {
            va_start(argumentList, otherButtonTitles);
            while ((eachObject = va_arg(argumentList, id))) {
                [actionSheet addButtonWithTitle:eachObject];
                
                destructiveButtonIndex = destructiveButtonIndex + 1;
            }
            va_end(argumentList);
        }
    }
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.destructiveButtonIndex = destructiveButtonIndex;
    [actionSheet showInView:view.window];
}

+(NSString *) getAvailStr:(id) str
{
    if (nil!=str && str!=[NSNull null]) {
        if ([str isKindOfClass:[NSString class]]) {
            if (![str isEqualToString:@"<null>"] && ![str isEqualToString:@"NaN"]) {
                return str;
            }else{
                return @"";
            }
        }
        
        return str;
    }
    
    return @"";
}

@end
