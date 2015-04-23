//
//  NSString+MogeneratorExtensions.m
//  mogenerator
//
//  Created by Oleksii Taran on 4/23/15.
//
//

#import "NSString+MogeneratorExtensions.h"
#import <MiscMerge/NSString+MiscAdditions.h>
#import "FoundationAdditions.h"

@implementation NSString (camelCaseString)

- (NSString*)camelCaseString {
    NSArray *lowerCasedWordArray = [[self wordArray] arrayByMakingObjectsPerformSelector:@selector(lowercaseString)];
    NSUInteger wordIndex = 1, wordCount = [lowerCasedWordArray count];
    NSMutableArray *camelCasedWordArray = [NSMutableArray arrayWithCapacity:wordCount];
    if (wordCount)
        [camelCasedWordArray addObject:[lowerCasedWordArray objectAtIndex:0]];
    for (; wordIndex < wordCount; wordIndex++) {
        [camelCasedWordArray addObject:[[lowerCasedWordArray objectAtIndex:wordIndex] initialCapitalString]];
    }
    return [camelCasedWordArray componentsJoinedByString:@""];
}

@end
