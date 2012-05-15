//
//  NSArray+StringElementsAdditions.m
//  Wallnut
//
//  Created by Devarshi Kulshreshtha on 11/05/12.
//  Copyright (c) 2012 DaemonConstruction. All rights reserved.
//

#import "NSArray+StringElementsAdditions.h"
@interface NSArray ()
- (NSArray *)mapEachElementUsingBlock:(NSString *(^)(NSString *))aBlock;
@end

@implementation NSArray (StringElementsAdditions)
- (NSArray *)addPrefix:(NSString *)aPrefix
{
    return [self mapEachElementUsingBlock:^NSString *(NSString *object) {
        return [aPrefix stringByAppendingString:object];
    }];
}
- (NSArray *)mapEachElementUsingBlock:(NSString *(^)(NSString *))aBlock
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:2];
    
    for (id object in self)
    {
        if ([object isKindOfClass:[NSString class]]) {
            [tempArray addObject:aBlock(object)];
        }
    }
    
    return [NSArray arrayWithArray:tempArray];
}
@end
