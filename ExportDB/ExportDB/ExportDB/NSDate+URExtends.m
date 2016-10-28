//
//  NSDate+URExtends.m
//  NewDriver4iOS
//
//  Created by wangjueMBP on 16/4/21.
//  Copyright © 2016年 苼茹夏花. All rights reserved.
//

#import "NSDate+URExtends.h"

@implementation NSDate (URExtends)
- (NSDate *)UR_getNowDateFromatAnDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:self];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:self];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:self];
    return destinationDateNow;
}

+ (NSString *)UR_convertTimeStampToDate:(NSString *)timeStamp dateFormat:(NSString *)dataFormat
{
    double unixTimeStamp = [timeStamp doubleValue];
    NSTimeInterval _interval = unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter = [[NSDateFormatter alloc]init];
    [_formatter setLocale:[NSLocale currentLocale]];
    [_formatter setDateFormat:dataFormat];
    NSString *_date = [_formatter stringFromDate:date];
    return _date;
}

- (long long)UR_convertDateToTimeStamp
{
   return [self timeIntervalSince1970] * 1000;
}

- (long long)UR_convertDateToTimeStampSecond
{
    return [self timeIntervalSince1970];
}

- (NSDate *)yesterday
{
    return [self addDay:-1];
}

- (NSDate *)tomorrow
{
    return [self addDay:1];
}

- (NSDate *)addDay:(NSInteger)addDay
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    //    components.timeZone = [NSTimeZone timeZoneWithName:@"GMT+8"];
    components.timeZone = [NSTimeZone localTimeZone];
    [components setDay:addDay];
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = components.timeZone;
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

-(NSString *)toStringWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:format];
    NSString *strDate = [dateFormatter stringFromDate:self];
    return strDate;
}

@end
