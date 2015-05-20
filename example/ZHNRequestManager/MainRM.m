//
//  MainRM.m
//  ZHNRequestManager
//
//  Created by vi on 14/05/2015.
//
//

#import "MainRM.h"

@implementation MainRM

- (NSString*) serverUrlString
{
    return @"https://salon-capsula.com:3434/v1";
}

- (void) loadDataForce:(BOOL)isforce
                params:(NSDictionary*)params
{
    [self requestURLString:@"/salons" params:params requestType:RequestTypeGET requestParams:nil];
}

- (void) parseResult:(id)result
              params:(NSDictionary*)params
{
    sleep(1);
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (NSString*) notificationNameWhenFail
{
    return kRequestFail;
}

- (NSString*) notificationNameWhenSuccess
{
    return kRequestSuccess;
}


@end
