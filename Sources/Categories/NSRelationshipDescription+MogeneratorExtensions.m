//
//  NSRelationshipDescription+MogeneratorExtensions.m
//  mogenerator
//
//  Created by Oleksii Taran on 4/23/15.
//
//

#import "NSRelationshipDescription+MogeneratorExtensions.h"

@interface NSRelationshipDescription ()

- (BOOL)isOrdered;

@end

@implementation NSRelationshipDescription (collectionClassName)

- (NSString *)mutableCollectionClassName {
    return [self jr_isOrdered] ? @"NSMutableOrderedSet" : @"NSMutableSet";
}

- (NSString *)immutableCollectionClassName {
    return [self jr_isOrdered] ? @"NSOrderedSet" : @"NSSet";
}

- (BOOL)jr_isOrdered {
    if ([self respondsToSelector:@selector(isOrdered)]) {
        return [self isOrdered];
    } else {
        return NO;
    }
}

@end
