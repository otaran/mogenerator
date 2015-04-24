//
//  MogeneratorTemplateDesc.m
//  mogenerator
//
//  Created by Oleksii Taran on 4/25/15.
//
//

#import "MogeneratorTemplateDesc.h"
#import <MiscMerge/MiscMergeEngine.h>
#import <MiscMerge/MiscMergeTemplate.h>

@implementation MogeneratorTemplateDesc

- (instancetype)initWithName:(NSString *)name path:(NSString *)path
{
    self = [super init];
    if (self) {
        self.templateName = name;
        self.templatePath = path;
    }
    return self;
}

- (void)dealloc
{
    self.templateName = nil;
    self.templatePath = nil;
    [super dealloc];
}

- (MiscMergeEngine *)engine
{
    MiscMergeTemplate *template = [[[MiscMergeTemplate alloc] init] autorelease];
    [template setStartDelimiter:@"<$" endDelimiter:@"$>"];
    if (self.templatePath) {
        [template parseContentsOfFile:self.templatePath];
    } else {
        NSData *templateData = [[NSBundle mainBundle] objectForInfoDictionaryKey:self.templateName];
        assert(templateData);
        NSString *templateString = [[[NSString alloc] initWithData:templateData encoding:NSASCIIStringEncoding] autorelease];
        [template setFilename:[@"x-__info_plist://" stringByAppendingString:self.templateName]];
        [template parseString:templateString];
    }
    
    return [[[MiscMergeEngine alloc] initWithTemplate:template] autorelease];
}

@end
