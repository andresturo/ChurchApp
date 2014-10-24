//
//  CCIndexPath.m
//  RedilApp
//
//  Created by Daniel Cardona on 10/18/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "CCIndexPath.h"

@implementation CCIndexPath

#pragma mark -NSObject

-(BOOL)isEqual:(id)object{
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[NSIndexPath class]]) {
        return NO;
    }
    return [self isEqualToIndexPath:(NSIndexPath*)object];
}

-(BOOL)isEqualToIndexPath:(NSIndexPath*)indexPath{
    
    BOOL haveEqualRows = self.row == indexPath.row;
    BOOL haveEqualSections = self.section == indexPath.section;
    
    return haveEqualRows && haveEqualSections;
}

-(NSUInteger)hash{
    return [self hash];
}

#pragma mark - NSCoding

-(id)initWithCoder:(NSCoder *)aDecoder{
//    self = [super init];
    NSInteger row = [aDecoder decodeIntegerForKey:@"row"];
    NSInteger section = [aDecoder decodeIntegerForKey:@"section"];
//    if (self)
    self = (CCIndexPath*)[NSIndexPath indexPathForRow:row inSection:section];
    
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeInteger:self.row forKey:@"row"];
    [aCoder encodeInteger:self.section forKey:@"section"];
}


@end
