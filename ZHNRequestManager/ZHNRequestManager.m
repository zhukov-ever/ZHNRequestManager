//
//  ZHNRequestManager.m
//  ZHNRequestManager
//
//  Created by vi on 8/05/2015.
//
//

#import "ZHNRequestManager.h"
#import "ZHNFile.h"
#import "AFHTTPRequestOperationManager.h"


static NSMutableSet* m_requestsPool;
static dispatch_queue_t m_queue;

@interface ZHNRequestManager()

@property (nonatomic, readonly) NSMutableSet* requestsPool;

@end




@implementation ZHNRequestManager

#pragma mark - public

- (void) loadDataForce:(BOOL)isforce
                params:(NSDictionary*)params
{
    NSAssert(false, @"%s must be overridden!", __PRETTY_FUNCTION__);
}

- (void) parseResult:(id)result
              params:(NSDictionary*)params
{
    NSAssert(false, @"%s must be overridden!", __PRETTY_FUNCTION__);
}




#pragma mark - protected

- (NSString*) queueIdentifier
{
    return [NSBundle mainBundle].bundleIdentifier;
}

- (BOOL) logging
{
    return YES;
}

- (NSString*) serverUrlString
{
    NSAssert(false, @"%s must be overridden!", __PRETTY_FUNCTION__);
    return nil;
}

- (NSDictionary*) httpHeaders
{
    return @{@"Content-type":@"application/x-www-form-urlencoded"};
}

- (NSInteger) timeout
{
    return 10;
}

- (BOOL) allowInvalidCertificates
{
    return NO;
}


- (void) requestURLString:(NSString*)urlString
                   params:(NSDictionary*)params
              requestType:(RequestTypes)requestType
            requestParams:(NSDictionary*)requestParams
{
    [self requestURLString:urlString params:params requestType:requestType requestParams:requestParams requestFiles:nil];
}

- (void) requestURLString:(NSString*)urlString
                   params:(NSDictionary*)params
              requestType:(RequestTypes)requestType
            requestParams:(NSDictionary*)requestParams
             requestFiles:(NSArray*)requestFiles
{
    NSAssert(urlString != nil, @"urlString must not be nil");
    
    NSString* _stringForPool = [self requestHashForPool:[[self serverUrlString] stringByAppendingPathComponent:urlString]
                                            requestType:requestType
                                          requestParams:requestParams
                                           requestFiles:requestFiles];
    
    if ([self.requestsPool containsObject:_stringForPool])
    {
        if ([self logging])
        {
            NSLog(@"request already in process:\n%@\n", [[self serverUrlString] stringByAppendingPathComponent:urlString]);
        }
        return;
    }
    else
    {
        if ([self logging])
        {
            NSLog(@"request will be executed:\n%@\n", [[self serverUrlString] stringByAppendingPathComponent:urlString]);
        }
    }
    [self.requestsPool addObject:_stringForPool];
    
    AFHTTPRequestOperationManager* _manager = [self constructHTTPManager];
    NSMutableURLRequest* _request = [self constructURLRequest:urlString httpManager:_manager requestType:requestType requestParams:requestParams requestFiles:requestFiles];
    
    [self executeRequest:_request manager:_manager params:params requestHash:_stringForPool];
}

- (NSString*) notificationNameWhenFail
{
    NSAssert(false, @"%s must be overridden!", __PRETTY_FUNCTION__);
    return nil;
}

- (NSString*) notificationNameWhenSuccess
{
    NSAssert(false, @"%s must be overridden!", __PRETTY_FUNCTION__);
    return nil;
}




#pragma mark - private

- (NSMutableSet *)requestsPool
{
    if (!m_requestsPool)
        m_requestsPool = [NSMutableSet new];
    return m_requestsPool;
}

- (NSString*) requestHashForPool:(NSString*)urlString
                     requestType:(RequestTypes)requestType
                   requestParams:(NSDictionary*)requestParams
                    requestFiles:(NSArray*)requestFiles
{
    NSString* _string42 = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@",
                           [[self serverUrlString] stringByAppendingPathComponent:urlString],
                           [self requestTypeFactory:requestType],
                           [requestParams description],
                           requestFiles == nil ? @"0" : @"1",
                           [self notificationNameWhenFail],
                           [self notificationNameWhenSuccess]];
    
    return _string42;
}

- (void) executeRequest:(NSMutableURLRequest*)request
                manager:(AFHTTPRequestOperationManager*)manager
                 params:(NSDictionary*)params
            requestHash:(NSString*)requestHash
{
    __block NSDictionary* _params = params;
    __block NSString* _requestHash = requestHash;
    
    AFHTTPRequestOperation* _requestOperation = nil;
    _requestOperation = [manager HTTPRequestOperationWithRequest:request
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject)
                         {
                             if (!m_queue)
                             {
                                 m_queue = dispatch_queue_create([[self queueIdentifier] UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
                             }
                             
                             dispatch_async(m_queue, ^{
                                 if ([self logging])
                                 {
                                     NSLog(@"request success:\n%@", _requestHash);
                                 }
                                 [self parseResult:responseObject params:_params];
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self.requestsPool removeObject:_requestHash];
                                     [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationNameWhenSuccess] object:nil];
                                 });
                             });
                         }
                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
                         {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if ([self logging])
                                 {
                                     NSLog(@"request FAILED:\n%@\nerror:\n%@\n%@", _requestHash, [error localizedDescription], [operation responseString]);
                                 }
                                 [self.requestsPool removeObject:_requestHash];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationNameWhenFail] object:nil userInfo:error.userInfo];
                             });
                         }];
    
    [_requestOperation start];
}

- (AFHTTPRequestOperationManager*) constructHTTPManager
{
    AFHTTPRequestOperationManager* _manager = [AFHTTPRequestOperationManager manager];
    
    AFSecurityPolicy* _securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    _securityPolicy.allowInvalidCertificates = [self allowInvalidCertificates];
    _manager.securityPolicy = _securityPolicy;
    
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    for (NSString* _key in [self httpHeaders])
    {
        [_manager.requestSerializer setValue:[[self httpHeaders] objectForKey:_key] forHTTPHeaderField:_key];
    }
    [_manager.requestSerializer setTimeoutInterval:[self timeout]];
    
    return _manager;
}

- (NSMutableURLRequest*) constructURLRequest:(NSString*)urlString
                                 httpManager:(AFHTTPRequestOperationManager*)manager
                                 requestType:(RequestTypes)requestType
                               requestParams:(NSDictionary*)requestParams
                                requestFiles:(NSArray*)requestFiles
{
    NSMutableURLRequest *_request = nil;
    NSError* _error = nil;
    if (requestFiles && [requestFiles count] > 0)
    {
        _request = [manager.requestSerializer multipartFormRequestWithMethod:[self requestTypeFactory:requestType]
                                                                   URLString:[[self serverUrlString] stringByAppendingPathComponent:urlString]
                                                                  parameters:requestParams
                                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                    {
                        for (ZHNFile* _file in requestFiles)
                        {
                            [formData appendPartWithFileData:_file.data
                                                        name:_file.name
                                                    fileName:_file.fileName
                                                    mimeType:_file.mimeType];
                        }
                    } error:&_error];
    }
    else
    {
        _request = [manager.requestSerializer requestWithMethod:[self requestTypeFactory:requestType]
                                                      URLString:[[self serverUrlString] stringByAppendingPathComponent:urlString]
                                                     parameters:requestParams
                                                          error:&_error];
    }
    
    _request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    return _request;
}


- (NSString*) requestTypeFactory:(RequestTypes)requestType
{
    switch (requestType)
    {
        case RequestTypeGET:
            return @"GET";
        case RequestTypePOST:
            return @"POST";
        case RequestTypePUT:
            return @"PUT";
        case RequestTypeDELETE:
            return @"DELETE";
    }
    
    NSAssert(false, @"undefined requestType");
    return nil;
}


@end