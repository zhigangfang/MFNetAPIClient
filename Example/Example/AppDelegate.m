//
//  AppDelegate.m
//  Example
//
//  Created by 房志刚 on 21/3/2017.
//  Copyright © 2017 bjdv. All rights reserved.
//

#define BASE_URL @"http://beta.json-generator.com"

#import "AppDelegate.h"

#import "MFNetAPIClient.h"
#import "NSString+MFCommon.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //普通模式
    [[MFNetAPIClientManager clientWithBaseURL:[NSURL URLWithString:BASE_URL]] requestJsonDataWithPath:@"/api/json/get/Nyj-xhtif" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        
        //do something here.
        NSLog(@"1==%@", data);
        
    }];
    
    
    //参差业务判断
//    http://beta.json-generator.com/api/json/get/E15soRtsG
    MFNetAPIClient *client = [MFNetAPIClientManager clientWithBaseURL:[NSURL URLWithString:BASE_URL]];
    //配置接口返回参数名
    [client setResponseConfig:[[MFNetResponseConfig alloc] initWithCodeName:@"resultCode" msgNmae:@"resultMsg"]];
    
    [client requestJsonDataWithPath:@"/api/json/get/E15soRtsG" withParams:nil withMethodType:Get successBlock:^(id data) {
        
        //here 'resultCode' = 0
        NSLog(@"2==%@", data);
    } failBlock:^(id data, NSError *error) {
        
        //here 'resultCode' = 1   or   other network error
        
    } defaultBlock:^{
        //default do something, such as hide hud.
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
