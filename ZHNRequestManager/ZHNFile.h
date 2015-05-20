//
//  ZHNFile.h
//  ZHNRequestManager
//
//  Created by vi on 8/05/2015.
//
//

#import <Foundation/Foundation.h>

@interface ZHNFile : NSObject

@property (nonatomic, strong) NSData* data;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* fileName;
@property (nonatomic, copy) NSString* mimeType;

@end
