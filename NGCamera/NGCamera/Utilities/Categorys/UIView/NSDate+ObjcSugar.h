//
//  NSDate+ObjcSugar.h
//  NGCamera
//
//  Created by caizhepeng on 2019/8/29.
//  Copyright © 2019年 caizhepeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ObjcSugar)

/// 获取年月日对象
- (NSDateComponents *)YMDComponents;

/**************************  当前年月日  *****************************/

/// 这个月有多少天
- (NSUInteger)numberOfDaysInCurrentMonth;

/// 计算当前这个月有几周
- (NSUInteger)numberOfWeeksInCurrentMonth;

/// 计算当前这个月的时间
- (NSString *)dateOfCurrentMonth;

/// 计算这个月最开始的一天
- (NSDate *)firstDayOfCurrentMonth;

/// 计算这个月最后的一天
- (NSDate *)lastDayOfCurrentMonth;





/**************************  某天年月日  *****************************/

/// 计算某天当月有多少天
- (NSUInteger)numberOfDaysInCurrentMonth:(NSString *)dateString;

/// 计算某天周的时间
- (NSString *)theDayOfWeek:(NSString *)dateString;

/// 计算某天当月的第几周
- (NSInteger)indexOfWeeksInMonthWithDate:(NSString *)dateString;

/// 计算某天当周的日期数组
- (NSArray *)dateArrayOfCurrentWeek:(NSString *)dateString;

/// 计算某天月的时间
- (NSString *)theDayOfMonth:(NSString *)dateString;

/// 计算某天当月的数组
- (NSArray *)dateArrayOfCurrentMonth:(NSString *)dateString;





/**************************  距离年月日时间  *****************************/

/// 上一个月
- (NSDate *)dayInThePreviousMonth;

/// 下一个月
- (NSDate *)dayInTheFollowingMonth;

/// 距离现在的上几个月
- (NSDate *)dayInThePreviousDistanceMonth:(NSInteger)month;

/// 距离现在的下几个月
- (NSDate *)dayInTheFollowingDistanceMonth:(NSInteger)month;

/// 获取当前日期之后的几个月
- (NSDate *)dayInTheFollowingMonth:(int)month;

/// 获取当前日期之后的几个天
- (NSDate *)dayInTheFollowingDay:(int)day;

/// 获取当前日期之前的几个天
- (NSDate *)dayInThePreviousDay:(int)day;

/// 获取某天日期之前的几个天
- (NSString *)dayInThePreviousDay:(int)day dateString:(NSString *)dateString;




/**************************  时间格式转换  *****************************/

/// NSString转NSDate return:NSDateFormatter
+ (NSDateFormatter *)setDateFormatString:(NSString *)formatString;

/// NSString转NSDate
- (NSDate *)dateFromString:(NSString *)dateString dateFormat:(NSString *)dateFormat;

/// NSDate转NSString
- (NSString *)stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat;

/// NSDate转NSString UTC
- (NSString *)stringUTCFromString:(NSString *)dateString;




/**************************  两个时间之差  *****************************/

/// 两个日期相差几天
+ (int)getDayNumbertoDay:(NSDate *)today beforDay:(NSDate *)beforday;

/// 两个日期相差几天数组
- (NSArray *)getDayArraytoDay:(NSDate *)today beforeDate:(NSDate *)beforeDay;

/// 两个日期相差几分钟
+ (int)getMinuteNumbertoDay:(NSDate *)today beforDay:(NSDate *)beforday;




/***************************  判断星期  *****************************/

/// 计算当天是星期几
- (NSUInteger)weeklyOrdinality;

/// 计算某天是礼拜几
- (NSUInteger)weeklyOrdinality:(NSString *)dateString;

/// 周日是“1”，周一是“2”...
- (int)getWeekIntValueWithDate;

/// 判断日期是今天,明天,后天,周几
- (NSString *)compareIfTodayWithDate;
/// 通过数字返回星期几
+ (NSString *)getWeekStringFromInteger:(int)week;

/// 计算当前日期属于第几周
- (NSInteger)currentWeek;




@end
