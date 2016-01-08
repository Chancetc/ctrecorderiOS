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

#define CTRecordBegin [[CTRecorder getInstance] recordTheBegining:@"comic" for:NSStringFromSelector(_cmd)];
#define CTRecordEnd [[CTRecorder getInstance] recordTheEnding:@"comic" for:NSStringFromSelector(_cmd)];
#define CTRecord_ [[CTRecorder getInstance] record:@"comic" for:NSStringFromSelector(_cmd)];
#define CTRecord(a) [[CTRecorder getInstance] record:@"comic" for:[NSString stringWithFormat:@"%@_%@",NSStringFromSelector(_cmd),a]];

#else

#define CTRecordBegin  
#define CTRecordEnd
#define CTRecord_
#define CTRecord(a)

#endif

#endif /* CTRecorderDef_h */
