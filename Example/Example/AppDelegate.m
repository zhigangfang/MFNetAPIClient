//
//  AppDelegate.m
//  Example
//
//  Created by 房志刚 on 21/3/2017.
//  Copyright © 2017 bjdv. All rights reserved.
//

#import "AppDelegate.h"

#import "MFNetAPIClient.h"
#import "NSString+MFCommon.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /*
    NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NewLine" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"NSString类方法读取的内容是：\n%@",content);
    
    NSString *newContent = [content mf_removeUnescapedCharacter];
    
    NSError *serializationError = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[newContent dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&serializationError];
     
     */
    
    [[MFNetAPIClient sharedClient] requestJsonDataWithPath:@"http://beta.json-generator.com/api/json/get/Nyj-xhtif" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        
        
        
    }];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end