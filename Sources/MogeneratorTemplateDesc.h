//
//  MogeneratorTemplateDesc.h
//  mogenerator
//
//  Created by Oleksii Taran on 4/25/15.
//
//

#import <Foundation/Foundation.h>

@interface MogeneratorTemplateDesc : NSObject

@property (nonatomic, retain) NSString *templateName;
@property (nonatomic, retain) NSString *templatePath;

- (id)initWithName:(NSString*)name_ path:(NSString*)path_;

@end
