//
//  NSDate+URExtends.h
//  NewDriver4iOS
//
//  Created by wangjueMBP on 16/4/21.
//  Copyright © 2016年 苼茹夏花. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (URExtends)
- (NSDate *)UR_getNowDateFromatAnDate;

+ (NSString *)UR_convertTimeStampToDate:(NSString *)timeStamp dateFormat:(NSString *)dataFormat;

- (long long)UR_convertDateToTimeStamp;

- (long long)UR_convertDateToTimeStampSecond;

- (NSDate *)yesterday;

- (NSDate *)tomorrow;

- (NSDate *)addDay:(NSInteger)addDay;

-(NSString *)toStringWithFormat:(NSString *)format;
@end
