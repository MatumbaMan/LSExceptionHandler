//
//  CrashHandler.m
//  LSExceptionHandler
//
//  Created by HouKinglong on 16/4/19.
//  Copyright © 2016年 HouKinglong. All rights reserved.
//

#import "CrashHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

#define CrashExceptionHandlerSignalExceptionName    @"CrashExceptionHandlerSignalExceptionName"
#define CrashExceptionHandlerSignalKey              @"CrashExceptionHandlerSignalKey"
#define CrashExceptionHandlerAddressesKey           @"CrashExceptionHandlerAddressesKey"

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@interface CrashHandler (){
    BOOL dismissed;
}

@end

@implementation CrashHandler

/*
 * register crash handler
 */
void InstallUncaughtExceptionHandler(void)
{
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +
         UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

/*
 * save exception to file
 */
- (void)validateAndSaveCriticalApplicationData:(NSException *)exception
{
    NSLog(@"[crash] - reason:%@\n%@", [exception reason], [[exception userInfo] objectForKey:CrashExceptionHandlerAddressesKey]);
}

//- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
//{
//    if (anIndex == 0)
//    {
//        dismissed = YES;
//    }else if (anIndex==1) {
//        NSLog(@"ssssssss");
//    }
//}

- (void)handleException:(NSException *)exception
{
    [self validateAndSaveCriticalApplicationData:exception];
    
//    UIAlertView *alert =
//    [[UIAlertView alloc]
//     initWithTitle:NSLocalizedString(@"抱歉，程序出现了异常", nil)
//     message:[NSString stringWithFormat:NSLocalizedString(
//                                                          @"如果点击继续，程序有可能会出现其他的问题，建议您还是点击退出按钮并重新打开\n\n"
//                                                          @"异常原因如下:\n%@\n%@", nil),
//              [exception reason],
//              [[exception userInfo] objectForKey:CrashExceptionHandlerAddressesKey]]
//     delegate:self
//     cancelButtonTitle:NSLocalizedString(@"退出", nil)
//     otherButtonTitles:NSLocalizedString(@"继续", nil), nil] ;
//    [alert show];

    dismissed = YES;
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed)
    {
        for (NSString *mode in (__bridge NSArray *)allModes)
        {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:CrashExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:CrashExceptionHandlerSignalKey] intValue]);
    }
    else
    {
        [exception raise];
    }
}

void HandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSArray *callStack = [CrashHandler backtrace];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:CrashExceptionHandlerAddressesKey];
    
    [[[CrashHandler alloc]init]performSelectorOnMainThread:@selector(handleException:) withObject: [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo] waitUntilDone:YES];
}

void SignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:CrashExceptionHandlerSignalKey];
    
    NSArray *callStack = [CrashHandler backtrace];
    [userInfo setObject:callStack forKey:CrashExceptionHandlerAddressesKey];
    
    [[[CrashHandler alloc] init] performSelectorOnMainThread:@selector(handleException:) withObject: [NSException exceptionWithName:CrashExceptionHandlerSignalExceptionName reason: [NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.", nil), signal] userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:CrashExceptionHandlerSignalKey]] waitUntilDone:YES];
}

@end
