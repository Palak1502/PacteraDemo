//
//  ParseJsonData.h
//  PacteraDemo


#import <Foundation/Foundation.h>

@interface ParseJsonData : NSObject

/***************************************************************
 * Function Name        : initWithJsonParser
 * Description          : Json Parser
 * Input parameters     : (NSDictionary *)jsonDictionary
 * output parameters    : responseObject
 * return values        : id
 ***************************************************************/
-(id)initWithJsonParser:(NSDictionary *)jsonDictionary;

@property (readonly)  NSMutableArray *receiverData;
@end
