//
//  CrashHandler.h
//  LSExceptionHandler
//
//  Created by HouKinglong on 16/4/19.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashHandler : NSObject

void HandleException(NSException *exception);
void SignalHandler(int signal);

/************************************************************
 @func name : void InstallUncaughtExceptionHandler(void)
 @func desc : register crash handler
 @func param : N/A
 @func return : N/A
 **********************************************************/
void InstallUncaughtExceptionHandler(void);

@end
