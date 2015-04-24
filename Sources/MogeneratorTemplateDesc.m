//
//  MogeneratorTemplateDesc.m
//  mogenerator
//
//  Created by Oleksii Taran on 4/25/15.
//
//

#import "MogeneratorTemplateDesc.h"

@implementation MogeneratorTemplateDesc

- (id)initWithName:(NSString*)name_ path:(NSString*)path_ {
    self = [super init];
    if (self) {
        self.templateName = name_;
        self.templatePath = path_;
    }
    return self;
}

- (void)dealloc {
    self.templateName = nil;
    self.templatePath = nil;
    [super dealloc];
}

@end
