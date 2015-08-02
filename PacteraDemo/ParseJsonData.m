//
//  ParseJsonData.m
//  PacteraDemo


#import "ParseJsonData.h"
#import "CountryRecord.h"
#import "PDConstants.h"

// string contants found in the RSS feed


@interface ParseJsonData ()

@end


#pragma mark -

@implementation ParseJsonData

// -------------------------------------------------------------------------------
//	initWithDataJsonParser:
// -------------------------------------------------------------------------------
- (id)initWithJsonParser:(NSDictionary *)jsonDictionary
{
   if(self = [self init]) {
       _receiverData= [[NSMutableArray alloc]init];
       NSString *titleString = [jsonDictionary objectForKey:title];
       NSArray *rowsArray = [jsonDictionary objectForKey:rows];

       for(NSDictionary *dict in rowsArray){
           CountryRecord *countryRecord = [[CountryRecord alloc]init];
           id titleRow = [dict objectForKey:title];
           id descRow = [dict objectForKey:description];
           id imageRow = [dict objectForKey:imageHref];
           countryRecord.title = (titleRow != [NSNull null])?(NSString*)titleRow : emptyString;
           countryRecord.desc = (descRow != [NSNull null])?(NSString*)descRow : emptyString;
           countryRecord.imageURLString =(imageRow != [NSNull null])?(NSString*)imageRow : emptyString;
           [_receiverData addObject:countryRecord];
       }
   }
    return self;
}



@end
