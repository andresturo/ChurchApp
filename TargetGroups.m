//
//  TargetGroups.m
//  CoreDataTransformable
//
//  Created by Daniel Cardona on 10/28/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import "TargetGroups.h"

@implementation TargetGroups

+(Class)transformedValueClass{
    
    return [NSArray class];
}
+(BOOL)allowsReverseTransformation{
    
    return YES;
}

-(id)transformedValue:(id)value{
    
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

-(id)reverseTransformedValue:(id)value{
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
