//
//  CTRecorder.h
//  QQComic
//
//  Created by Chanceguo on 15/12/22.
//  Copyright © 2015年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CTRecordModel : NSObject<NSCopying>

/**
 @brief identifier for a recorder
 */
@property (nonatomic, strong) NSString *identifier;

/**
 @brief 记录开始的时间
 */
@property (nonatomic, strong) NSDate *startDate;

/**
 @brief 上次记录的时间点
 */
@property (nonatomic, strong) NSDate *lastDate;

@property (nonatomic, strong) NSString *lastDesp;

/**
 @brief 总耗时
 */
@property (nonatomic, assign) NSUInteger totalTimeGap;

/**
 @brief 
 value:gap of times in millisecond
 key:description of the gap
 */
@property (nonatomic, strong) NSMutableDictionary *timeGapDics;

/**
 @brief keep keys in order
 */
@property (nonatomic, strong) NSMutableArray *orderKeys;

/**
 @brief record times
 */
@property (nonatomic, strong) NSMutableArray *timeStamps;

@property (nonatomic, strong) NSMutableArray *orderKeysForTimeStamps;

@end

@interface CTRecorder : NSObject

+(instancetype)getInstance;

/**
 @brief 单条记录的开始
 
 @param identifier 标识符
 */
-(void)recordTheBegining:(NSString*)identifier for:(NSString*)description;

/**
 @brief 单条记录的结束
 
 @param identifier 标志性符
 */
-(void)recordTheEnding:(NSString*)identifier for:(NSString*)description;

/**
 @brief 记录中间时间点
 
 @param description 描述
 */
-(void)record:(NSString *)identifier for:(NSString*)description;

/**
 @brief 输出对应的记录描述
 
 @param identifier 标志符
 
 @return 描述
 */
-(NSString*)getTheDescriptionOf:(NSString*)identifier;

@end
