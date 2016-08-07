//
//  CTRecorder.m
//  QQComic
//
//  Created by Chanceguo on 15/12/22.
//  Copyright © 2015年 Tencent. All rights reserved.
//

#import "CTRecorder.h"
#import "CTRecorderDef.h"

//#import "AFNetworking.h"
//#import "QQForwardEngine+ShareApp.h"
@implementation CTRecordModel

-(instancetype)init{
    
    if (self =[super init]) {
        _timeGapDics = [NSMutableDictionary new];
        _timeStamps = [NSMutableArray new];
        _orderKeys = [NSMutableArray new];
        _orderKeysForTimeStamps = [NSMutableArray new];
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone{

    CTRecordModel *copyModel = [[CTRecordModel alloc] init];
    copyModel.identifier = [self.identifier mutableCopy];
    copyModel.startDate = [self.startDate copy];
    copyModel.lastDate = [self.lastDate copy];
    copyModel.lastDesp = [self.lastDesp mutableCopy];
    copyModel.totalTimeGap = self.totalTimeGap;
    copyModel.timeGapDics = [self.timeGapDics mutableCopy];
    copyModel.orderKeys = [self.orderKeys mutableCopy];
    copyModel.timeStamps = [self.timeStamps mutableCopy];
    copyModel.orderKeysForTimeStamps = [self.orderKeysForTimeStamps mutableCopy];
    
    return copyModel;
}

-(NSString *)description{
    
    __block NSString *des = [NSString stringWithFormat:@"records of %@",self.identifier];
    des = [NSString stringWithFormat:@"%@;total cost:%@ cost destribution:",des,@(self.totalTimeGap)];
    [_orderKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        des = [NSString stringWithFormat:@"%@\n %@ : %@ ms",des,key,_timeGapDics[key]];
    }];
    
    return des;
}

@end

@interface CTRecorder(){
    
    NSMutableDictionary *_recordingDic;
    NSMutableDictionary *_recordedDic;
    NSMutableArray *_orderedKeys;
    dispatch_queue_t _recordQueue;
    NSTimeInterval _lastUploadTimestamp;
}

@end

@implementation CTRecorder

static CTRecorder *instace;

#pragma mark --life cycle
+(instancetype)getInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instace = [self new];
    });
    return instace;
}

-(instancetype)init{
    if (self = [super init]) {
        _recordedDic = [NSMutableDictionary new];
        _recordingDic = [NSMutableDictionary new];
        _orderedKeys = [NSMutableArray new];
        _recordQueue = dispatch_queue_create(@"COMIC_RECORDER".UTF8String, 0);
        _minUploadTimeInterval = -1;
    }
    return self;
}

#pragma mark --utility
-(void)recordTheBegining:(NSString *)identifier for:(NSString *)description{
    
    NSDate *curDate = [NSDate date];
    dispatch_async(_recordQueue, ^{
        NSString *simDes = [self simplifyIdentifier:description];
        [self printCurrentPoint:identifier identifier:simDes date:curDate];
        CTRecordModel *model = [self modelByIdentifier:identifier isBegining:YES];
        model.startDate = curDate;
        model.lastDate = curDate;
        model.lastDesp = simDes;
        @synchronized(model) {
            [model.timeStamps addObject:model.startDate];
            [model.orderKeysForTimeStamps addObject:simDes];
        }
    });
    
}

-(void)recordTheEnding:(NSString *)identifier for:(NSString *)description{
    
    NSDate *curDate = [NSDate date];
    
    dispatch_async(_recordQueue, ^{
        NSString *simDes = [self simplifyIdentifier:description];
        [self printCurrentPoint:identifier identifier:simDes date:curDate];
        //加一层保护：如果该记录已经结束记录状态则不再记录操作
        CTRecordModel *model = [self modelByIdentifier:identifier isBegining:NO];
        if (!model) {
            return ;
        }
        CGFloat timeInterval = ceil([curDate timeIntervalSinceDate:model.lastDate] * 100000)/100;
        
        @synchronized(model) {
            NSString *key = [NSString stringWithFormat:@"%@~%@",model.lastDesp,simDes];
            [model.timeGapDics setObject:@(timeInterval) forKey:key];
            [model.orderKeys addObject:key];
            model.lastDate = curDate;
            model.totalTimeGap  = ceil([model.lastDate timeIntervalSinceDate:model.startDate] * 100000)/100;
            [model.timeStamps addObject:model.lastDate];
            [model.orderKeysForTimeStamps addObject:simDes];
        }
        
        @synchronized(_recordedDic) {
            NSString *key = [NSString stringWithFormat:@"%@_%@",identifier,@(_orderedKeys.count)];
            [_orderedKeys addObject:key];
            [_recordedDic setObject:model forKey:key];
            [_recordingDic removeObjectForKey:identifier];
            model.lastDesp = simDes;
            if ([self isNeedUploadRecordData]) {
                [instace getTheDescriptionOf:identifier];
                
                //数据上报
                [instace uploadData:[instace currentReportDic]];
                [_recordedDic removeAllObjects];
                [_orderedKeys removeAllObjects];
            }
        }
    });
}

-(BOOL)isNeedUploadRecordData{

    BOOL dataEnough = _recordedDic.count >= 2;
    NSTimeInterval timeIntervalSince1970 = [[NSDate date] timeIntervalSince1970];
    
    //若未设置过最小时间间隔则直接使用默认值
    double minInterval = CTR_DEFUALT_UPLOAD_TIMEINTERVAL;
    if (self.minUploadTimeInterval > 0) {
        minInterval = self.minUploadTimeInterval;
    }
    BOOL timeEnough = (fabs(_lastUploadTimestamp-timeIntervalSince1970) > minInterval);
    return dataEnough && timeEnough;
}

-(void)record:(NSString *)identifier for:(NSString*)description{
    
    NSDate *curDate = [NSDate date];
    dispatch_async(_recordQueue, ^{
        NSString *simDes = [self simplifyIdentifier:description];
        [self printCurrentPoint:identifier identifier:simDes date:curDate];
        //加一层保护：如果该记录已经结束记录状态则不再记录操作
        CTRecordModel *model = [self modelByIdentifier:identifier isBegining:NO];
        if (!model) {
            return ;
        }
        NSString *newDes = simDes;
        CGFloat timeInterval = ceil([curDate timeIntervalSinceDate:model.lastDate] * 100000)/100;
        if (!simDes || simDes.length == 0) {
            newDes = [NSString stringWithFormat:@"OP_%@",@(timeInterval)];
        }
        
        @synchronized(model) {
            NSString *key = [NSString stringWithFormat:@"%@~%@",model.lastDesp,newDes];
            [model.timeGapDics setObject:@(timeInterval) forKey:key];
            [model.orderKeys addObject:key];
            model.lastDate = curDate;
            model.lastDesp = newDes;
            [model.timeStamps addObject:curDate];
            [model.orderKeysForTimeStamps addObject:simDes];
        }
    });
}

-(NSString *)getTheDescriptionOf:(NSString *)identifier{
    
    __block NSString *description = @"";
    __block CTRecordModel *anchorModel = nil;
    [_recordedDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, CTRecordModel *model, BOOL * _Nonnull stop) {
        anchorModel = model;
        description = [NSString stringWithFormat:@"%@%@",description,model];
        //        NSLog(@"CTRecoder :%@",model);
    }];
    
    if (!anchorModel) {
        return description;
    }
    NSString *chartStr = @"[";
    
    int idx = 0;
    for (NSString *key in anchorModel.orderKeys) {
        
        NSString *singleChartArrayStr = [NSString stringWithFormat:@"{name:'%@',data:[",key];
        int chartSigleCount = 0;
        
        for (NSString *modelKey in _orderedKeys) {
            CTRecordModel *model = _recordedDic[modelKey];
            //加一层保护格式不统一的记录将不被导出
            if (!model.orderKeys || !anchorModel.orderKeys || ![model.orderKeys.description isEqualToString:anchorModel.orderKeys.description]) {
                continue ;
            }
            if (chartSigleCount == 0) {
                singleChartArrayStr = [NSString stringWithFormat:@"%@%@",singleChartArrayStr,model.timeGapDics[key]];
            }else{
                singleChartArrayStr = [NSString stringWithFormat:@"%@,%@",singleChartArrayStr,model.timeGapDics[key]];
            }
            chartSigleCount ++;
        }
        
        singleChartArrayStr = [NSString stringWithFormat:@"%@]}",singleChartArrayStr];
        
        if (idx == 0) {
            chartStr = [NSString stringWithFormat:@"%@%@",chartStr,singleChartArrayStr];
        }else{
            chartStr = [NSString stringWithFormat:@"%@,%@",chartStr,singleChartArrayStr];
        }
        idx++;
    }
    
    chartStr = [NSString stringWithFormat:@"%@]",chartStr];
    
    description = [NSString stringWithFormat:@"%@\nhello world\n%@ hello world \n\n",description,chartStr];
    //    [[QQForwardEngine GetInstance] sendShareTextMsg:@"770422880" accType:ACCOSTTYPE_DEFAULT groupCode:nil withMsg:description attachMsg:nil appShareID:0 msgModel:nil];
    NSLog(@"%@",description);
    return description;
}

-(void)printCurrentPoint:(NSString*)tag identifier:(NSString*)identifier date:(NSDate*)date{

    NSLog(@"CTRecorder LOG -- time:%@ tag:%@ identifier:%@ ",@([date timeIntervalSince1970]),tag,identifier);
}

-(CTRecordModel *)modelByIdentifier:(NSString*)identifier isBegining:(BOOL)begining{
    
    CTRecordModel *model = nil;
    if (!identifier || identifier.length == 0) {
        identifier = @"defaultRecorder";
    }
    if ((model = _recordingDic[identifier]) || !begining) {
        return model;
    }
    
    @synchronized(_recordingDic) {
        model = [CTRecordModel new];
        model.identifier = identifier;
        [_recordingDic setObject:model forKey:identifier];
    }
    return model;
}

-(void)uploadData:(NSDictionary*)params{

//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
//    [manager POST:@"http://120.25.65.98:12321/uploadRecords" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
//        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        
//    }];
    
//    [[QQHttpClient shareInstance] enqueueRequestSession:
//                        [QQHttpClientSession
//                                    sessionWithURL:@"http://120.25.65.98:12321/uploadRecords"
//                                    bussiness:@[@(0)]
//                                    resource:QQNetReqResTypeGetJson
//                                    success:^(QQHttpClientSession *sess, id resObject) {
//        
//    }
//                                    fail:^(QQHttpClientSession *sess, NSError *err) {
//        
//    }]];
    
//    [NSMutableURLRequest tencentRequest:@"http://120.25.65.98:12321/uploadRecords" httpMethod:@"POST" timeout:60 params:params httpHeads:nil cookie:nil];
    
    // 请求地址
//    NSString *urlString = @"http://127.0.0.1:12321/uploadRecords";
    [CTRecorderHTTPClient CTRPostWith:UPLOAD_URL params:params completionHandler:^(NSURLResponse *response, id rspObj, NSError *connectionError) {
        NSLog(@"CTRecorder upload complete%@",rspObj);
        _lastUploadTimestamp = [[NSDate date] timeIntervalSince1970];
    }];
}


-(id)currentReportDic{
    
    NSMutableDictionary *copyRecords = [_recordedDic mutableCopy];
    NSMutableArray *copyKeys = [_orderedKeys mutableCopy];
    CTRecordModel *anchorModel = nil;
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    NSString *userName = [CTRecorder getInstance].userName;
    if (!userName) {
        userName = @"CTRecorder";
    }
    result[@"userName"] = userName;
    NSMutableArray *records = [NSMutableArray new];
    for (NSInteger i = (copyKeys.count - 1); i >= 0; i--) {
        
        NSString *key = copyKeys[i];
        CTRecordModel *model = copyRecords[key];
        if (i == (copyKeys.count - 1)) {
            anchorModel = copyRecords[key];
        }
        
        if (!model.identifier
            ||!anchorModel.identifier
            ||![model.identifier isEqualToString:anchorModel.identifier]
            ||!model.orderKeys
            ||!anchorModel.orderKeys
            ||![model.orderKeys.description isEqualToString:anchorModel.orderKeys.description]) {
            
            continue ;
        }
        
        NSMutableDictionary *recordDic = [NSMutableDictionary new];
        recordDic[@"recordTag"] = model.identifier;
        recordDic[@"recordDate"] = [NSString stringWithFormat:@"%@",@(ceil([model.startDate timeIntervalSince1970] * 100000)/100)];
        recordDic[@"points"] = [self pointsFromRecodModel:model];
        [records addObject:recordDic];
    }
    result[@"records"] = records;
    
    return result;
}

-(NSMutableArray*)pointsFromRecodModel:(CTRecordModel*)model{

    NSMutableArray *arr = [NSMutableArray new];
    if (model) {
        for (int i=0; i<model.orderKeysForTimeStamps.count; i++) {
            NSString *key = model.orderKeysForTimeStamps[i];
            NSDate *date = (NSDate*)model.timeStamps[i];
            CGFloat timestamp = ceil([date timeIntervalSince1970] * 100000)/100;
            
            [arr addObject:@{@"timestamp":[NSString stringWithFormat:@"%@",@(timestamp)],
                             @"key":key,
                             @"index":@(i)}];
        }
    }
    return arr;
}

-(NSString*)simplifyIdentifier:(NSString*)identifier{

    NSMutableString *newIdentifier = [NSMutableString stringWithString:identifier];
    NSDictionary *replaceDic = @{
                                 @"QQ":@"",
                                 @"VIP":@"",
                                 @"Function":@"",
                                 @"View":@"V",
                                 @"Controller":@"C",
                                 @"Web":@"W",
                                 @"Download":@"DL",
                                 @"Notification":@"noti",
                                 @"Button":@"bt",
                                 @"Label":@"Lbl",
                                 @"NS":@"",
                                 @"UI":@"",
                                 @"Array":@"Arr",
                                 @"Mutable":@"Mut",
                                 @"table":@"t",
                                 @"Database":@"db",
                                 @"define":@"def",
                                 @"manage":@"mg",
                                 @"recent":@"rct",
                                 @"Selector":@"SEL",
                                 @"progress":@"prgs",
                                 @"window":@"w"
                                 };
    NSArray *replaceKeys = replaceDic.allKeys;
    for (NSString *key in replaceKeys) {
        
        NSString *lowerId = [newIdentifier lowercaseString];
        NSString *lowerKey = [key lowercaseString];
        if ([lowerId containsString:lowerKey]) {
            [newIdentifier replaceOccurrencesOfString:key withString:replaceDic[key] options:NSCaseInsensitiveSearch range:NSMakeRange(0, newIdentifier.length)];
        }
    }
    return newIdentifier;
}
@end
