//
//  MogeneratorTemplateDesc.h
//  mogenerator
//
//  Created by Oleksii Taran on 4/25/15.
//
//

#import <Foundation/Foundation.h>

@class MiscMergeEngine;

@interface MogeneratorTemplateDesc : NSObject

@property (nonatomic, retain) NSString *templateName;
@property (nonatomic, retain) NSString *templatePath;

- (instancetype)initWithName:(NSString *)name path:(NSString *)path;

- (MiscMergeEngine *)engine;

@end
