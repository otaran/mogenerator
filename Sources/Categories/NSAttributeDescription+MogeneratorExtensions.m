//
//  NSAttributeDescription+MogeneratorExtensions.m
//  mogenerator
//
//  Created by Oleksii Taran on 4/23/15.
//
//

#import "NSAttributeDescription+MogeneratorExtensions.h"
#import "GlobalVariables.h"
#import "UserInfoKeys.h"

@implementation NSAttributeDescription (typing)

- (BOOL)isUnsigned
{
    BOOL hasMin = NO;
    for (NSPredicate *pred in [self validationPredicates]) {
        if ([pred.predicateFormat containsString:@">= 0"]) {
            hasMin = YES;
        }
    }
    return hasMin;
}

- (BOOL)hasScalarAttributeType {
    switch ([self attributeType]) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
        case NSBooleanAttributeType:
            return YES;
            break;
        default:
            return NO;
    }
}

- (NSString*)scalarAttributeType {
    
    BOOL isUnsigned = [self isUnsigned];
    
    NSString *attributeValueScalarType = [[self userInfo] objectForKey:kAttributeValueScalarTypeKey];
    
    if (attributeValueScalarType) {
        return attributeValueScalarType;
    } else {
        switch ([self attributeType]) {
            case NSInteger16AttributeType:
                return gSwift ? isUnsigned ? @"UInt16" : @"Int16" : isUnsigned ? @"uint16_t" : @"int16_t";
                break;
            case NSInteger32AttributeType:
                return gSwift ? isUnsigned ? @"UInt32" : @"Int32" : isUnsigned ? @"uint32_t" : @"int32_t";
                break;
            case NSInteger64AttributeType:
                return gSwift ? isUnsigned ? @"UInt64" : @"Int64" : isUnsigned ? @"uint64_t" : @"int64_t";
                break;
            case NSDoubleAttributeType:
                return gSwift ? @"Double" : @"double";
                break;
            case NSFloatAttributeType:
                return gSwift ? @"Float" : @"float";
                break;
            case NSBooleanAttributeType:
                return gSwift ? @"Bool" : @"BOOL";
                break;
            default:
                return nil;
        }
    }
}

- (NSString*)scalarAccessorMethodName {
    
    BOOL isUnsigned = [self isUnsigned];
    
    switch ([self attributeType]) {
        case NSInteger16AttributeType:
            if (isUnsigned) {
                return @"unsignedShortValue";
            }
            return @"shortValue";
            break;
        case NSInteger32AttributeType:
            if (isUnsigned) {
                return @"unsignedIntValue";
            }
            return @"intValue";
            break;
        case NSInteger64AttributeType:
            if (isUnsigned) {
                return @"unsignedLongLongValue";
            }
            return @"longLongValue";
            break;
        case NSDoubleAttributeType:
            return @"doubleValue";
            break;
        case NSFloatAttributeType:
            return @"floatValue";
            break;
        case NSBooleanAttributeType:
            return @"boolValue";
            break;
        default:
            return nil;
    }
}

- (NSString*)scalarFactoryMethodName {
    
    BOOL isUnsigned = [self isUnsigned];
    
    switch ([self attributeType]) {
        case NSInteger16AttributeType:
            if (isUnsigned) {
                return @"numberWithUnsignedShort:";
            }
            return @"numberWithShort:";
            break;
        case NSInteger32AttributeType:
            if (isUnsigned) {
                return @"numberWithUnsignedInt:";
            }
            return @"numberWithInt:";
            break;
        case NSInteger64AttributeType:
            if (isUnsigned) {
                return @"numberWithUnsignedLongLong:";
            }
            return @"numberWithLongLong:";
            break;
        case NSDoubleAttributeType:
            return @"numberWithDouble:";
            break;
        case NSFloatAttributeType:
            return @"numberWithFloat:";
            break;
        case NSBooleanAttributeType:
            return @"numberWithBool:";
            break;
        default:
            return nil;
    }
}

- (BOOL)hasDefinedAttributeType {
    return [self attributeType] != NSUndefinedAttributeType;
}

- (NSString*)objectAttributeClassName {
    NSString *result = nil;
    if ([self hasTransformableAttributeType]) {
        result = [[self userInfo] objectForKey:@"attributeValueClassName"];
        if (!result) {
            result = gSwift ? @"AnyObject" : @"NSObject";
        }
    } else {
        result = [self attributeValueClassName];
    }
    if (gSwift && [result isEqualToString:@"NSString"]) {
        result = @"String";
    }
    return result;
}

- (NSArray*)objectAttributeTransformableProtocols {
    if ([self hasAttributeTransformableProtocols]) {
        NSString *protocolsString = [[self userInfo] objectForKey:@"attributeTransformableProtocols"];
        NSCharacterSet *removeCharSet = [NSCharacterSet characterSetWithCharactersInString:@", "];
        NSMutableArray *protocols = [NSMutableArray arrayWithArray:[protocolsString componentsSeparatedByCharactersInSet:removeCharSet]];
        [protocols removeObject:@""];
        return protocols;
    }
    return nil;
}

- (BOOL)hasAttributeTransformableProtocols {
    return [self hasTransformableAttributeType] && [[self userInfo] objectForKey:@"attributeTransformableProtocols"];
}

- (NSString*)objectAttributeType {
    NSString *result = [self objectAttributeClassName];
    if ([result isEqualToString:@"Class"]) {
        // `Class` (don't append asterisk).
    } else if ([result rangeOfString:@"<"].location != NSNotFound) {
        // `id<Protocol1,Protocol2>` (don't append asterisk).
    } else if ([result isEqualToString:@"NSObject"]) {
        result = gSwift ? @"AnyObject" : @"id";
    } else if (!gSwift) {
        result = [result stringByAppendingString:@"*"]; // Make it a pointer.
    }
    return result;
}

- (BOOL)hasTransformableAttributeType {
    return ([self attributeType] == NSTransformableAttributeType);
}

- (BOOL)isReadonly {
    NSString *readonlyUserinfoValue = [[self userInfo] objectForKey:@"mogenerator.readonly"];
    if (readonlyUserinfoValue != nil) {
        return YES;
    }
    return NO;
}

@end
