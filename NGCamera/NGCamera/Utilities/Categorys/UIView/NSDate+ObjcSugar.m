//
//  NSDate+ObjcSugar.m
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import "NSDate+ObjcSugar.h"

@implementation NSDate (ObjcSugar)

#pragma mark Formatter单例
+ (NSDateFormatter *)sharedDateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    
    return dateFormatter;
}

#pragma mark Calendar单例
+ (NSCalendar *)sharedCalendar {
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    
    return calendar;
}

#pragma mark 计算这个月有多少天
- (NSUInteger)numberOfDaysInCurrentMonth
{
    return [[NSDate sharedCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}

#pragma mark 计算某天当月有多少天
- (NSUInteger)numberOfDaysInCurrentMonth:(NSString *)dateString
{
    return [[self dateFromString:dateString dateFormat:@"yyyy.MM.dd"] numberOfDaysInCurrentMonth];
}

#pragma mark 获取这个月有多少周
- (NSUInteger)numberOfWeeksInCurrentMonth
{
    //计算这个月的第一天是礼拜几
    NSUInteger weekday = [[self firstDayOfCurrentMonth] weeklyOrdinality];
    NSUInteger days = [self numberOfDaysInCurrentMonth];
    NSUInteger weeks = 0;
    
    if (weekday > 1) {
        (void)(weeks += 1), days -= (7 - weekday + 1);
    }
    
    weeks += days / 7;
    weeks += (days % 7 > 0) ? 1 : 0;
    
    return weeks;
}

#pragma mark 计算某天属于当月第几周
- (NSInteger)indexOfWeeksInMonthWithDate:(NSString *)dateString
{
    return [[self dateFromString:dateString dateFormat:@"yyyy.MM.dd"] currentWeek];
}

#pragma mark 计算当前日期属于第几周
- (NSInteger)currentWeek
{
    //计算这个月的第一天是礼拜几
    NSUInteger weekday = [[self firstDayOfCurrentMonth] weeklyOrdinality];
    NSUInteger days = [self YMDComponents].day;
    
    NSUInteger daysOfMonth = [self numberOfDaysInCurrentMonth];
    NSUInteger currentWeek = 0;
    
    //计算这个月的最后一天是礼拜几
    NSInteger lastWeekDay = [[self lastDayOfCurrentMonth] weeklyOrdinality];
    
    if (weekday > 1) {
        currentWeek += 1;
        days -= (7 - weekday + 1);
        daysOfMonth -= (7 - weekday + 1);
    }
    currentWeek += days / 7;
    currentWeek += (days % 7 > 0) ? 1 : 0;
    
    if (lastWeekDay != 7 && days > daysOfMonth - lastWeekDay) {
        currentWeek = 1;
    }
    
    return currentWeek;
    
}

#pragma mark 计算某天周的时间
- (NSString *)theDayOfWeek:(NSString *)dateString
{
    return  [[self dateFromString:dateString dateFormat:@"yyyy.MM.dd"] dateStringOfCurrentWeek];
    
}

#pragma mark 计算当前日期周的时间
- (NSString *)dateStringOfCurrentWeek
{
    int week = (int)[self weeklyOrdinality];
    
    int startDay = week - 1;
    int endDay = 7 - week;
    
    //周的开始日期
    NSString *startWeek = [self stringFromDate:[self dayInThePreviousDay:startDay] dateFormat:@"yyyy.MM.dd"];
    //周的结束日期
    NSString *endWeek = [self stringFromDate:[self dayInTheFollowingDay:endDay] dateFormat:@"yyyy.MM.dd"];
    //拼接
    NSString *dateOfCurrentWeek = [NSString stringWithFormat:@"%@-%@",startWeek,endWeek];
    
    return dateOfCurrentWeek;
}

#pragma mark 计算当周的日期数组
- (NSArray *)dateArrayOfCurrentWeek:(NSString *)dateString
{
    return  [[self dateFromString:dateString dateFormat:@"yyyy.MM.dd"] dateArrayOfCurrentWeek];
}

#pragma mark 计算当周的日期数组
- (NSArray *)dateArrayOfCurrentWeek
{
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        int startDay = (int)[self weeklyOrdinality] - (i + 1);
        NSString *dateString = [self stringFromDate:[self dayInThePreviousDay:startDay] dateFormat:@"MM.dd"];
        [arrayM addObject:dateString];
    }
    
    return [arrayM copy];
}

#pragma mark 计算某天月的时间
- (NSString *)theDayOfMonth:(NSString *)dateString
{
    return  [[self dateFromString:dateString dateFormat:@"yyyy.MM.dd"] dateOfCurrentMonth];
}

#pragma mark 计算当前日期月的时间
- (NSString *)dateOfCurrentMonth
{
    NSString *startDayOfMonth = [self stringFromDate:[self firstDayOfCurrentMonth] dateFormat:@"yyyy.MM.dd"];
    NSString *endDayOfMonth = [self stringFromDate:[self lastDayOfCurrentMonth] dateFormat:@"yyyy.MM.dd"];
    
    //拼接
    NSString *dateOfCurrentMonth = [NSString stringWithFormat:@"%@-%@",startDayOfMonth,endDayOfMonth];
    return dateOfCurrentMonth;
}

#pragma mark 计算某天当月的数组
- (NSArray *)dateArrayOfCurrentMonth:(NSString *)dateString
{
    return  [[self dateFromString:dateString dateFormat:@"yyyy.MM.dd"] dateArrayOfCurrentMonth];
}

#pragma mark 计算当前日期月的数组
- (NSArray *)dateArrayOfCurrentMonth
{
    int numOfDays = (int)[self numberOfDaysInCurrentMonth];
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 0; i < numOfDays; i++) {
        NSDate *currentDate = [[self firstDayOfCurrentMonth] dayInTheFollowingDay:i];
        [arrayM addObject:[self stringFromDate:currentDate dateFormat:@"MM.dd"]];
    }
    return [arrayM copy];
}


#pragma mark 计算某天是礼拜几
-(NSUInteger)weeklyOrdinality:(NSString *)dateString
{
    return [[self dateFromString:dateString dateFormat:@"yyyy.MM.dd"] weeklyOrdinality];
}

#pragma mark 计算当天是礼拜几
- (NSUInteger)weeklyOrdinality
{
    return [[NSDate sharedCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:self];
}

#pragma mark 计算这个月最开始的一天
- (NSDate *)firstDayOfCurrentMonth
{
    NSDate *startDate = nil;
    BOOL ok = [[NSDate sharedCalendar] rangeOfUnit:NSCalendarUnitMonth startDate:&startDate interval:NULL forDate:self];
    NSAssert1(ok, @"Failed to calculate the first day of the month based on %@", self);
    return startDate;
}

#pragma mark 计算这个月最后的一天
- (NSDate *)lastDayOfCurrentMonth
{
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponents = [[NSDate sharedCalendar] components:calendarUnit fromDate:self];
    dateComponents.day = [self numberOfDaysInCurrentMonth];
    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

#pragma mark 上一个月
- (NSDate *)dayInThePreviousMonth
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    return [[NSDate sharedCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

#pragma mark 下一个月
- (NSDate *)dayInTheFollowingMonth
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = 1;
    return [[NSDate sharedCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}
#pragma mark 距离现在的上几个月
- (NSDate *)dayInThePreviousDistanceMonth:(NSInteger)distance
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1 * distance;
    return [[NSDate sharedCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

#pragma mark 距离现在的下几个月
- (NSDate *)dayInTheFollowingDistanceMonth:(NSInteger)distance
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = 1 * distance;
    return [[NSDate sharedCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

#pragma mark 获取当前日期之后的几个月
- (NSDate *)dayInTheFollowingMonth:(int)month
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = month;
    return [[NSDate sharedCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

#pragma mark 获取当前日期之后的几个天
- (NSDate *)dayInTheFollowingDay:(int)day
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = day;
    return [[NSDate sharedCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

#pragma mark 获取当前日期之前的几个天
- (NSDate *)dayInThePreviousDay:(int)day
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = -day;
    return [[NSDate sharedCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
}

#pragma mark 获取某天日期之前的几天
- (NSString *)dayInThePreviousDay:(int)day dateString:(NSString *)dateString
{
    NSDate *previousDate = [[self dateFromString:dateString dateFormat:@"yyyy.MM.dd"] dayInThePreviousDay:day];
    return [self stringFromDate:previousDate dateFormat:@"yyyy.MM.dd"];
}

#pragma mark 获取年月日对象
- (NSDateComponents *)YMDComponents
{
    return [[NSDate sharedCalendar] components:
            NSCalendarUnitYear|
            NSCalendarUnitMonth|
            NSCalendarUnitDay|
            NSCalendarUnitWeekday|NSCalendarUnitWeekOfMonth fromDate:self];
}

#pragma mark NSString转NSDate
- (NSDate *)dateFromString:(NSString *)dateString dateFormat:(NSString *)dateFormat
{
    NSDateFormatter * formatter = [NSDate sharedDateFormatter];
    formatter.timeZone = [NSTimeZone defaultTimeZone];
    formatter.calendar = [NSDate sharedCalendar];
    [formatter setDateFormat:dateFormat]; //yyyy-MM-dd HH:mm:ss
    NSDate * date = [formatter dateFromString:dateString];
    return date;
}


+ (NSDateFormatter *)setDateFormatString:(NSString *)formatString
{
    NSDateFormatter * formatter = [self sharedDateFormatter];
    formatter.timeZone = [NSTimeZone defaultTimeZone];
    formatter.calendar = [NSDate sharedCalendar];
    [formatter setDateFormat:formatString];
    return formatter;
}

#pragma mark NSDate转NSString
- (NSString *)stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat;
{
    NSDateFormatter *dateFormatter = [NSDate sharedDateFormatter];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:dateFormat]; //yyyy-MM-dd HH:mm:ss zzz
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    dateFormatter.calendar = [NSDate sharedCalendar];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

#pragma mark NSDate转NSStringb UTC
- (NSString *)stringUTCFromString:(NSString *)dateString
{
    NSDate *currentDate = [[NSDate date] dateFromString:dateString dateFormat:@"yyyy.MM.dd HH:mm"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    return [dateFormatter stringFromDate:currentDate];
}

+ (int)getDayNumbertoDay:(NSDate *)today beforDay:(NSDate *)beforday
{
    NSDateComponents *components = [[self sharedCalendar] components:NSCalendarUnitDay fromDate:today toDate:beforday options:0];
    //    NSDateComponents *components = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today toDate:beforday options:0];
    int day = (int)[components day];//两个日历之间相差多少月//    NSInteger days = [components day];//两个之间相差几天
    return day;
}

+ (int)getMinuteNumbertoDay:(NSDate *)today beforDay:(NSDate *)beforday
{
    NSDateComponents *components = [[self sharedCalendar] components:NSCalendarUnitMinute fromDate:today toDate:beforday options:0];
    int minute = (int)[components minute];
    return minute;
}

- (NSArray *)getDayArraytoDay:(NSDate *)today beforeDate:(NSDate *)beforeDay
{
    NSMutableArray *arrayM = [NSMutableArray array];
    int days = [NSDate getDayNumbertoDay:beforeDay beforDay:today] + 1;
    for (int i = 0; i < days; i++) {
        NSString *dateString = [self stringFromDate:[beforeDay dayInTheFollowingDay:i] dateFormat:@"yyyy.MM.dd"];
        [arrayM addObject:dateString];
    }
    return [arrayM copy];
}

#pragma mark 周日是“1”，周一是“2”...
- (int)getWeekIntValueWithDate
{
    int weekIntValue;
    
    NSCalendar *calendar = [NSDate sharedCalendar];
    NSDateComponents *comps= [calendar components:(NSCalendarUnitYear |
                                                   NSCalendarUnitMonth |
                                                   NSCalendarUnitDay |
                                                   NSCalendarUnitWeekday) fromDate:self];
    return weekIntValue = (int)[comps weekday];
}

#pragma mark 判断日期是今天,明天,后天,周几
-(NSString *)compareIfTodayWithDate
{
    NSDate *todate = [NSDate date];//今天
    NSCalendar *calendar = [NSDate sharedCalendar];
    NSDateComponents *comps_today= [calendar components:(NSCalendarUnitYear |
                                                         NSCalendarUnitMonth |
                                                         NSCalendarUnitDay |
                                                         NSCalendarUnitWeekday) fromDate:todate];
    
    
    NSDateComponents *comps_other= [calendar components:(NSCalendarUnitYear |
                                                         NSCalendarUnitMonth |
                                                         NSCalendarUnitDay |
                                                         NSCalendarUnitWeekday) fromDate:self];
    
    
    //获取星期对应的数字
    int weekIntValue = [self getWeekIntValueWithDate];
    
    if (comps_today.year == comps_other.year &&
        comps_today.month == comps_other.month &&
        comps_today.day == comps_other.day) {
        return @"今天";
        
    }else if (comps_today.year == comps_other.year &&
              comps_today.month == comps_other.month &&
              (comps_today.day - comps_other.day) == -1){
        return @"明天";
        
    }else if (comps_today.year == comps_other.year &&
              comps_today.month == comps_other.month &&
              (comps_today.day - comps_other.day) == -2){
        return @"后天";
        
    }else{
        //直接返回当时日期的字符串(这里让它返回空)
        return [NSDate getWeekStringFromInteger:weekIntValue];//周几
    }
}



#pragma mark 通过数字返回星期几
+(NSString *)getWeekStringFromInteger:(int)week
{
    NSString *str_week;
    
    switch (week) {
        case 1:
            str_week = @"周日";
            break;
        case 2:
            str_week = @"周一";
            break;
        case 3:
            str_week = @"周二";
            break;
        case 4:
            str_week = @"周三";
            break;
        case 5:
            str_week = @"周四";
            break;
        case 6:
            str_week = @"周五";
            break;
        case 7:
            str_week = @"周六";
            break;
    }
    return str_week;
}

@end
