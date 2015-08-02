//
//  ServiceClient.h
//  PacteraDemo
//


#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface ServiceClient : NSObject

/***************************************************************
 * Function Name        : getDetailOfCanada
 * Description          : Get JSon Data using AFNetworking
 * Input parameters     : (NSDictionary *json)
 * output parameters    : responseObject
 * return values        : Success/Failure
 ***************************************************************/

+ (void)getDetailsOfCanada:(void (^)(AFHTTPRequestOperation *operation, NSDictionary *json))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
