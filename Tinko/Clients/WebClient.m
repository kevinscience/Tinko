//
//  WebClient.m
//  Tinko
//
//  Created by Donghua Xue on 1/7/18.
//  Copyright © 2018 KevinScience. All rights reserved.
//

#import "WebClient.h"
#import <AFHTTPSessionManager.h>
#import "NSDictionary.h"

@implementation WebClient

-(void)participateOrLeaveMeetWithCode:(NSString*)code withMeetId:(NSString*)meetId withFacebookId:(NSString*)facebookId withCompletion:(void (^)(void))completion withError:(void (^)(NSString *error))errorBlock{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSString *urlString = [NSString stringWithFormat:@"https://us-central1-tinko-64673.cloudfunctions.net/%@?userFacebookId=%@&meetId=%@", code, facebookId, meetId];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            errorBlock([error localizedDescription]);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            
            if(completion) completion();
        }
    }];
    [dataTask resume];
}


-(void)postMethodWithCode:(NSString*)code withData:(NSDictionary*)data withCompletion:(void (^)(void))completion withError:(void (^)(NSString *error))errorBlock{
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
//    NSString *urlString = [NSString stringWithFormat:@"https://us-central1-tinko-64673.cloudfunctions.net/%@", code];
//
//    //NSString *dataJson = [data bv_jsonStringWithPrettyPrint:NO];
//    //NSString *dataJson = @"{\"id\":\"John\"}";
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    [dict setObject:@"ert" forKey:@"id"];
//    [dict setObject:@"pas" forKey:@"password"];
//
//    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.responseSerializer = [AFJSONRequestSerializer serializer];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//
//    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
//
//    [manager POST:urlString parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//
//        if(completion) completion();
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"ERROR: %@", [error localizedDescription]);
//        if(error) errorBlock([error localizedDescription]);
//    }];
    NSURL *baseURL = [NSURL URLWithString:@"https://us-central1-tinko-64673.cloudfunctions.net/"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    [manager POST:code parameters:data progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"responseObject: %@", responseObject);
        if(completion) completion();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        errorBlock([error localizedDescription]);
    }];}

@end
