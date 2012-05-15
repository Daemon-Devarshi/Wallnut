//
//  URLStringTransformer.m
//  Wallnut
//
//  Created by Devarshi Kulshreshtha on 11/05/12.
//  Copyright (c) 2012 DaemonConstruction. All rights reserved.
//

#import "URLStringTransformer.h"

@implementation URLStringTransformer

+ (Class)transformedValueClass
{
    return [NSURL class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return (value == nil) ? nil : [value path];
}

- (id)reverseTransformedValue:(id)value
{
    return (value == nil) ? nil : [NSURL fileURLWithPath:value];
}
@end
