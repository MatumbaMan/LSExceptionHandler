###LSExceptionHandler
catch Crash for NSException

###Introduce:<br>
The development of iOS application, to solve the Crash problem is a problem. Crash is divided into two kinds, one is caused by exc bad access, access does not belong to the memory address of the process, there may be a memory access has been released; another is Objective-C uncaught exception (nsexception), causes the program to send itself the SIGABRT signal collapse. The In fact, for the Objective-C anomaly is not captured, we have a way to record it, if the log records properly, to solve the problem of the vast majority of the crash. Here for the UI thread and the background thread respectively.<br>

###how to use：<br>
1.#import "CrashHandler.h" int AppDelegate.m<br>
2.put this code 
```JAVA
InstallUncaughtExceptionHandler(); 
```
    in method
```JAVA
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
```
You can see terminal of Xcode when crash occured.<br>
Also you can define you own method to parse exception.<br>

