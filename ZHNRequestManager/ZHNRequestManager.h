//
//  ZHNRequestManager.h
//  ZHNRequestManager
//
//  Created by vi on 8/05/2015.
//
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, RequestTypes)
{
    RequestTypeGET = 0,
    RequestTypePOST = 1,
    RequestTypePUT = 2,
    RequestTypeDELETE = 3
};


@interface ZHNRequestManager : NSObject

#pragma mark - public


- (void) loadDataForce:(BOOL)isforce
                params:(NSDictionary*)params;

- (void) parseResult:(id)result
              params:(NSDictionary*)params;




#pragma mark - override this methods:

- (NSString*) queueIdentifier;

- (BOOL) logging;

- (NSString*) serverUrlString;

- (NSDictionary*) httpHeaders;

- (NSInteger) timeout;

- (BOOL) allowInvalidCertificates;


- (void) requestURLString:(NSString*)urlString
                   params:(NSDictionary*)params
              requestType:(RequestTypes)requestType
            requestParams:(NSDictionary*)requestParams;

- (void) requestURLString:(NSString*)urlString
                   params:(NSDictionary*)params
              requestType:(RequestTypes)requestType
            requestParams:(NSDictionary*)requestParams
             requestFiles:(NSArray*)requestFiles;

- (NSString*) notificationNameWhenFail;

- (NSString*) notificationNameWhenSuccess;

@end