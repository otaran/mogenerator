//
//  NSManagedObjectModel+MogeneratorExtensions.m
//  mogenerator
//
//  Created by Oleksii Taran on 4/23/15.
//
//

#import "NSManagedObjectModel+MogeneratorExtensions.h"
#import <ddcli/DDCommandLineInterface.h>
#import "NSEntityDescription+MogeneratorExtensions.h"

@implementation NSManagedObjectModel (entitiesWithACustomSubclassVerbose)

- (NSArray*)entitiesWithACustomSubclassInConfiguration:(NSString*)configuration_ verbose:(BOOL)verbose_ {
    NSMutableArray *result = [NSMutableArray array];
    NSArray* allEntities = nil;
    
    if (nil == configuration_) {
        allEntities = [self entities];
    }
    else if (NSNotFound != [[self configurations] indexOfObject:configuration_]){
        allEntities = [self entitiesForConfiguration:configuration_];
    }
    else {
        if (verbose_){
            ddprintf(@"No configuration %@ found in model. No files will be generated.\n(model configurations: %@)\n", configuration_, [self configurations]);
        }
        return nil;
    }
    
    if (verbose_ && [allEntities count] == 0){
        ddprintf(@"No entities found in model (or in specified configuration). No files will be generated.\n(model description: %@)\n", self);
    }
    
    for (NSEntityDescription *entity in allEntities) {
        NSString *entityClassName = [entity managedObjectClassName];
        
        if ([entity hasCustomClass]){
            [result addObject:entity];
        } else {
            if (verbose_) {
                ddprintf(@"skipping entity %@ (%@) because it doesn't use a custom subclass.\n",
                         entity.name, entityClassName);
            }
        }
    }
    
    return [result sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"managedObjectClassName"
                                                                                                     ascending:YES] autorelease]]];
}

@end