//
//  NSEntityDescription+MogeneratorExtensions.h
//  mogenerator
//
//  Created by Oleksii Taran on 4/23/15.
//
//

#import <CoreData/CoreData.h>

@interface NSEntityDescription (FetchedPropertiesAdditions)

- (NSDictionary *)fetchedPropertiesByName;

@end

@interface NSEntityDescription (userInfoAdditions)

- (BOOL)hasUserInfoKeys;
- (NSDictionary *)userInfoByKeys;

@end

@interface NSEntityDescription (customBaseClass)

- (BOOL)hasCustomClass;

@end
