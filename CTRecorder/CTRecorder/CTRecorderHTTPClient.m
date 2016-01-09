//
//  CTRecorderHTTPClient.m
//  QQComic
//
//  Created by Chanceguo on 16/1/9.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "CTRecorderHTTPClient.h"


@interface NSObject (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end

@implementation NSObject (BVJSONString)

-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end

static CTRecorderHTTPClient* instance;

@implementation CTRecorderHTTPClient

+(instancetype)sharedInstance{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CTRecorderHTTPClient alloc] init];
    });
    
    return instance;
}

+(void)CTRPostWith:(NSString *)url params:(NSDictionary *)params completionHandler:(void (^)(NSURLResponse *, id, NSError *))handler{

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [CTRecorderHTTPClient PostWith:url params:params completionHandler:handler];
    });
}

+(void)PostWith:(NSString *)urlStr params:(NSDictionary *)params completionHandler:(void (^)(NSURLResponse *, id, NSError *))handler{

    // 初始化一个NSURL对象
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 初始化一个请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 30;
    NSString *paraStr = [params bv_jsonStringWithPrettyPrint:YES];
    NSData *data = [paraStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    
    // 设置请求头信息-请求体长度
    NSString *contentLength = [NSString stringWithFormat:@"%@", @(data.length)];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    // 设置请求头信息-请求数据类型
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // 发送一个异步请求
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        id rspObj = [CTRecorderHTTPClient DictionaryWithData:data];
        handler(response,rspObj,error);
    }];
    [task resume];
}

+(NSDictionary *)DictionaryWithJsonString:(NSString*)jsonStr{

    if (!jsonStr || jsonStr.length == 0) {
        return nil;
    }
    
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    return [CTRecorderHTTPClient DictionaryWithData:jsonData];
}

+(NSDictionary *)DictionaryWithData:(NSData*)data{

    if (!data) {
        return nil;
    }
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return nil;
    }
    return dic;
}
@end
