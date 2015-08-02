
#import <Foundation/Foundation.h>

@class CountryRecord;

@interface IconDownloader : NSObject

@property (nonatomic, strong) CountryRecord *countryRecord;
@property (nonatomic, copy) void (^completionHandler)(void);

/***************************************************************
 * Function Name        : startDownload
 * Description          : Images download start event.
 ***************************************************************/
- (void)startDownload;
/***************************************************************
 * Function Name        : cancelDownload
 * Description          : Images download cancel event.
 ***************************************************************/
- (void)cancelDownload;

@end
