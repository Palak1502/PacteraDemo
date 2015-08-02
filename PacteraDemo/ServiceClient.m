//
//  ServiceClient.m
//  PacteraDemo
//


#import "ServiceClient.h"
#import "PDConstants.h"

@implementation ServiceClient



+ (void)getDetailsOfCanada:(void (^)(AFHTTPRequestOperation *operation, NSDictionary *json))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
     NSMutableDictionary* errorDetails = [NSMutableDictionary dictionary];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:kServer parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSUInteger status = [operation response].statusCode;
        if (status == 200) {
            success(operation,responseObject);
        } else {
            // Right now I am desplaying only one error for your reference so you can get idea that we can check multiple status and set error code such as status code 400,401.
            [errorDetails setValue:NSLocalizedString(@"Network.error", nil) forKey:NSLocalizedDescriptionKey];
            failure(operation, [NSError errorWithDomain:PDErrorDomain code:operation.response.statusCode userInfo:errorDetails]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [errorDetails setValue:NSLocalizedString(@"Network.error", nil) forKey:NSLocalizedDescriptionKey];
        failure(operation, [NSError errorWithDomain:PDErrorDomain code:operation.response.statusCode userInfo:errorDetails]);
    }];

}
@end
