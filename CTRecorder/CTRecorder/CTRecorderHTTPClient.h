//
//  CTRecorderHTTPClient.h
//  QQComic
//
//  Created by Chanceguo on 16/1/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTRecorderHTTPClient : NSObject

+(instancetype)sharedInstance;

+(void)CTRPostWith:(NSString*)url params:(NSDictionary*)params completionHandler:(void (^)(NSURLResponse* response, id rspObj, NSError* connectionError)) handler;

@end
