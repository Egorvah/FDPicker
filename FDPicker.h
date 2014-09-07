//
//  FDPicker.h
//  FormattedDatePicker
//
//  Created by Egor on 29/08/14.
//  Copyright (c) 2014 Egor. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FDPickerDay ( @"d" )
#define FDPickerMonth ( @"MMMM" )
#define FDPickerYear ( @"yyyy" )
//const NSString * FDPickerDay = @"dd";
//const NSString * FDPickerMonth = @"MMMM";
//const NSString * FDPickerYear = @"yyyy";

@interface FDPicker : UIPickerView<UIPickerViewDataSource, UIPickerViewDelegate>


@property (nonatomic, strong) NSDate *date;

/// The minimum year that a month picker can show.
@property (nonatomic, strong) NSNumber* minYear;

/// The maximum year that a month picker can show.
@property (nonatomic, strong) NSNumber* maxYear;

@property (nonatomic, strong) NSArray* format;
@property UIDatePickerMode* datePickerMode;

/// Font to be used for all rows.  Default: System Bold, size 24.
@property (nonatomic, strong) UIFont *font;

/// Color to be used for all "non coloured" rows.  Default: Black.
@property (nonatomic, strong) UIColor *fontColor;

@property (nonatomic, strong) NSArray *months;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) NSArray *days;

- (void) setDate:(NSDate *)aDate animated:(BOOL)animated;
- (void)setFormatPicker:(NSArray *)formatPicker;

@end
