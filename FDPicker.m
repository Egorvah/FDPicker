//
//  FDPicker.m
//  FormattedDatePicker
//
//  Created by Egor on 29/08/14.
//  Copyright (c) 2014 Egor. All rights reserved.
//

#import "FDPicker.h"

// Identifiers of components
#define MONTH ( 0 )
#define YEAR ( 1 )
#define DAY ( 2 )
// Identifies for component views
#define LABEL_TAG 43

#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )

@implementation FDPicker
const NSInteger bigRowCount = 1;
NSInteger minYear = 1900;
NSInteger maxYear = 2250;
const CGFloat rowHeight = 40.f;

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initPicker];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initPicker];
    }
    return self;
}

- (void)initPicker
{
    [self setDate:[NSDate date] animated:NO];
    self.months = [self nameOfMonths];
    self.years = [self nameOfYears];
    self.days = [self nameOfDays];

    self.format = @[FDPickerDay, FDPickerMonth, FDPickerYear];

    self.delegate = self;
    self.dataSource = self;
    
    NSDate *dateEightHoursAhead = [[NSDate date] dateByAddingTimeInterval:1];
    
    [self setDate:[NSDate date] animated:NO];
}

- (void)setFormatPicker:(NSArray *)formatPicker
{
    self.format = formatPicker;
    [self reloadAllComponents];
    [self setDate:self.date animated:NO];
}

- (void) setDate:(NSDate *)aDate animated:(BOOL)animated{
    self.date = aDate;
    
    int dateYear;
    int dateMonth;
    int dateDay;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:self.date];
    dateMonth = [components month];
    components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:self.date];
    dateYear = [components year];
    components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self.date];
    dateDay = [components day];
    
    for (int componentItem = 0; componentItem < [self.format count]; componentItem++) {
        NSString * componentPicker = [self.format objectAtIndex:componentItem];
        SWITCH (componentPicker) {
            CASE (FDPickerDay) {
                int rowIndex = dateDay - 2;
                if (rowIndex < 0) {
                    rowIndex = 0;
                }
                
                [self selectRow: rowIndex
                    inComponent: componentItem
                       animated: animated];
                break;
            }
            
            CASE (FDPickerMonth) {
                [self selectRow: dateMonth - 1
                    inComponent: componentItem
                       animated: animated];
                break;
            }
            
            CASE (FDPickerYear) {
                int rowIndex = dateYear - minYear;
                if (rowIndex < 0) {
                    rowIndex = 0;
                }
                
                [self selectRow: rowIndex
                    inComponent: componentItem
                       animated: animated];
                break;
            }
        }
    }
}

-(NSArray *)nameOfMonths
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    return [dateFormatter standaloneMonthSymbols];
}

-(NSArray *)nameOfYears
{
    NSMutableArray *years = [NSMutableArray array];
    
    for(NSInteger year = minYear; year <= maxYear; year++)
    {
        NSString *yearStr = [NSString stringWithFormat:@"%li", (long)year];
        [years addObject:yearStr];
    }
    return years;
}

-(NSArray *)nameOfDays
{
    NSMutableArray *days = [NSMutableArray array];
    for(NSInteger day = 1; day <= 31; day++)
    {
        NSString *dayStr = [NSString stringWithFormat:@"%li", (long)day];
        [days addObject:dayStr];
    }
    return days;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return [self componentWidth:component];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self.format count];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSString * componentPicker = [self.format objectAtIndex:component];
    SWITCH (componentPicker) {
        CASE (FDPickerDay) {
            return [self bigRowDaysCount];
            break;
        }
        
        CASE (FDPickerMonth) {
            return [self bigRowMonthCount];
            break;
        }
            
        CASE (FDPickerYear) {
            return [self bigRowYearCount];
            break;
        }
    }
    return 0;
}

-(UIView *)pickerView: (UIPickerView *)pickerView
           viewForRow: (NSInteger)row
         forComponent: (NSInteger)component
          reusingView: (UIView *)view
{
    BOOL selected = NO;
    
    NSString * componentPicker = [self.format objectAtIndex:component];
    
    SWITCH (componentPicker) {
        CASE (FDPickerDay) {
            NSInteger dayCount = [self.days count];
            NSString *dayName = [self.days objectAtIndex:(row % dayCount)];
            NSString *currenrDayName  = [self currentDateName:FDPickerDay];
            if([dayName isEqualToString:currenrDayName] == YES)
            {
                selected = YES;
            }
            break;
        }
        CASE (FDPickerMonth) {
            NSInteger monthCount = [self.months count];
            NSString *monthName = [self.months objectAtIndex:(row % monthCount)];
            NSString *currentMonthName = [self currentDateName:FDPickerMonth];
            if([monthName isEqualToString:currentMonthName] == YES)
            {
                selected = YES;
            }
            break;
        }
        CASE (FDPickerYear) {
            NSInteger yearCount = [self.years count];
            NSString *yearName = [self.years objectAtIndex:(row % yearCount)];
            NSString *currenrYearName  = [self currentDateName:FDPickerYear];
            if([yearName isEqualToString:currenrYearName] == YES)
            {
                selected = YES;
            }
            break;
        }
    }
    
    UILabel *returnView = nil;
    if(view.tag == LABEL_TAG)
    {
        returnView = (UILabel *)view;
    }
    else
    {
        returnView = [self labelForComponent: component selected: selected];
    }
    
    returnView.text = [self titleForRow:row forComponent:component];
    return returnView;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return rowHeight;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

    NSString * stringFormat = nil;
    NSString * stringDate = nil;
    
    for (int componentItem = 0; componentItem < [self.format count]; componentItem++) {
        NSString * componentPicker = [self.format objectAtIndex:componentItem];
        SWITCH (componentPicker) {
            CASE (FDPickerDay) {
                if (stringFormat == nil)
                    stringFormat = [NSString stringWithFormat:@"%@", FDPickerDay];
                else
                    stringFormat = [NSString stringWithFormat:@"%@:%@", stringFormat, FDPickerDay];
                
                NSString *day = [NSString  stringWithFormat:@"%d", [[self.days objectAtIndex:([self selectedRowInComponent:componentItem])] intValue] + 1];
                
                if (stringDate == nil)
                    stringDate = [NSString stringWithFormat:@"%@", day];
                else
                    stringDate = [NSString stringWithFormat:@"%@:%@", stringDate, day];
                
                break;
            }
            
            CASE (FDPickerMonth) {
                if (stringFormat == nil)
                    stringFormat = [NSString stringWithFormat:@"%@", FDPickerMonth];
                else
                    stringFormat = [NSString stringWithFormat:@"%@:%@", stringFormat, FDPickerMonth];
                
                NSInteger monthCount = [self.months count];
                NSString *month = [self.months objectAtIndex:([self selectedRowInComponent:componentItem])];
                
                if (stringDate == nil)
                    stringDate = [NSString stringWithFormat:@"%@", month];
                else
                    stringDate = [NSString stringWithFormat:@"%@:%@", stringDate, month];
                
                break;
            }
            
            CASE (FDPickerYear) {
                if (stringFormat == nil)
                    stringFormat = [NSString stringWithFormat:@"%@", FDPickerYear];
                else
                    stringFormat = [NSString stringWithFormat:@"%@:%@", stringFormat, FDPickerYear];
                
                NSInteger yearCount = [self.years count];
                NSString *year = [self.years objectAtIndex:([self selectedRowInComponent:componentItem] % yearCount)];
                
                if (stringDate == nil)
                    stringDate = [NSString stringWithFormat:@"%@", year];
                else
                    stringDate = [NSString stringWithFormat:@"%@:%@", stringDate, year];
                break;
            }
        }
    }
    
    if (![self.format containsObject:FDPickerDay])
    {
        if (stringFormat == nil)
            stringFormat = [NSString stringWithFormat:@"%@", FDPickerDay];
        else
            stringFormat = [NSString stringWithFormat:@"%@:%@", stringFormat, FDPickerDay];
        
        if (stringDate == nil)
            stringDate = [NSString stringWithFormat:@"2"];
        else
            stringDate = [NSString stringWithFormat:@"%@:2", stringDate];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init]; [formatter setDateFormat:stringFormat];
    NSDate *date = [formatter dateFromString:stringDate];
    [self setDate:date animated:NO];
}

-(NSInteger)bigRowMonthCount
{
    return [self.months count]  * bigRowCount;
}

-(NSInteger)bigRowYearCount
{
    return [self.years count]  * bigRowCount;
}

-(NSInteger)bigRowDaysCount
{
    return [self.days count]  * bigRowCount;
}

-(CGFloat)componentWidth:(NSInteger)component
{
    CGFloat windowWidth = self.bounds.size.width - 40;
    NSString * componentPicker = [self.format objectAtIndex:component];
    SWITCH (componentPicker) {
        CASE (FDPickerDay) {
            return (windowWidth / 2) / 2;
        }
        
        CASE (FDPickerMonth) {
            return windowWidth / 2;
        }
        
        CASE (FDPickerYear) {
            return (windowWidth / 2) / 2;
        }
    }
    
    return windowWidth / [self.format count];
}

-(NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString * componentPicker = [self.format objectAtIndex:component];
    SWITCH (componentPicker) {
        CASE (FDPickerDay) {
            NSInteger daysCount = [self.days count];
            return [self.days objectAtIndex:(row % daysCount)];
        }
        
        CASE (FDPickerMonth) {
            NSInteger monthCount = [self.months count];
            return [self.months objectAtIndex:(row % monthCount)];
        }
        
        CASE (FDPickerYear) {
            NSInteger yearCount = [self.years count];
            return [self.years objectAtIndex:(row % yearCount)];
        }
    }
    
    return nil;
}

-(UILabel *)labelForComponent:(NSInteger)component selected:(BOOL)selected
{
    CGRect frame = CGRectMake(0.f, 0.f, [self componentWidth:component],rowHeight);
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    
    switch (component) {
        case 1:
            label.textAlignment = UITextAlignmentLeft;
            break;
            
        default:
            label.textAlignment = UITextAlignmentCenter;
            break;
    }
//    label.textAlignment = UITextAlignmentCenter; //UITextAlignmentCenter
    
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize: 24.f];
    label.userInteractionEnabled = NO;
    label.tag = LABEL_TAG;
    
    return label;
}

-(NSString *)currentDateName:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:[NSDate date]];
}

@end
