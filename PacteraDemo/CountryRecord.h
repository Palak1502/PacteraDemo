//
//  CountryRecord.h
//  PacteraDemo
//  Model class for load data for the Country.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CountryRecord : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) UIImage *eventIcon;
@property (nonatomic, strong) NSString *imageURLString;
@end
