//
//  NSManagedObjectModel+MogeneratorExtensions.h
//  mogenerator
//
//  Created by Oleksii Taran on 4/23/15.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectModel (entitiesWithACustomSubclassVerbose)

- (NSArray*)entitiesWithACustomSubclassInConfiguration:(NSString*)configuration_ verbose:(BOOL)verbose_;

@end
