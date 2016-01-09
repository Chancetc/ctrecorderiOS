//
//  CTRecorderDef.h
//  CTRecorder
//
//  Created by Chance_xmu on 16/1/8.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#ifndef CTRecorderDef_h
#define CTRecorderDef_h

#ifdef DEBUG 
#import "CTRecorder.h"
#import "CTRecorderHTTPClient.h"


#define INIT_CTRECORDER_WITH_NAME(USERNAME) [CTRecorder getInstance].userName = USERNAME;

//-----**默认方法只支持同时间只有一种记录任务在执行，多任务执行请使用后面的方法------****//

/**
 @brief 起始点
 
 @param _cmd 默认以方法名作为单点标记
 */
#define CTRecordBegin [[CTRecorder getInstance] recordTheBegining:@"comic" for:[NSString stringWithFormat:@"begin@%s:%@",__FILE__,NSStringFromSelector(_cmd)]];

/**
 @brief 结束点
 
 @param _cmd 默认以方法名作为单点标记
 */
#define CTRecordEnd [[CTRecorder getInstance] recordTheEnding:@"comic" for:[NSString stringWithFormat:@"end@%s:%@",__FILE__,NSStringFromSelector(_cmd)]];

/**
 @brief 中间点
 
 @param _cmd 默认以方法名作为单点标记
 */
#define __CTRecord__ [[CTRecorder getInstance] record:@"comic" for:[NSString stringWithFormat:@"%s:%@",__FILE__,NSStringFromSelector(_cmd)]];

/**
 @brief 中间点
 
 @param a 默认以方法名作为单点标记
 */
#define CTRecord(IDENTIFIER) [[CTRecorder getInstance] record:@"comic" for:[NSString stringWithFormat:@"%s:%@@%@",__FILE__,NSStringFromSelector(_cmd),IDENTIFIER]];

//------**单任务方法结束**---------//

//-------**多任务同时执行接口,请确保同一任务的TAG是相同的，并且不同任务的TAG是不同的**---------//

#define CTRecordAdvBegin(TAG) [[CTRecorder getInstance] recordTheBegining:TAG for:[NSString stringWithFormat:@"begin@%s:%@",__FILE__,NSStringFromSelector(_cmd)]];

#define CTRecordAdvEnd(TAG) [[CTRecorder getInstance] recordTheEnding:TAG for:[NSString stringWithFormat:@"end@%s:%@",__FILE__,NSStringFromSelector(_cmd)]];

#define __CTRecordAdv(TAG) [[CTRecorder getInstance] record:TAG for:[NSString stringWithFormat:@"%s:%@",__FILE__,NSStringFromSelector(_cmd)]];


#define CTRecordAdv(TAG,IDENTIFIER) [[CTRecorder getInstance] record:TAG for:[NSString stringWithFormat:@"%s:%@@%@",__FILE__,NSStringFromSelector(_cmd),IDENTIFIER]];


#else

#define CTRecordBegin  
#define CTRecordEnd
#define __CTRecord__
#define CTRecord(IDENTIFIER)

#define CTRecordAdvBegin(TAG)
#define CTRecordAdvEnd(TAG)
#define __CTRecordAdv(TAG)
#define CTRecordAdv(TAG,IDENTIFIER)


#endif

#endif /* CTRecorderDef_h */
