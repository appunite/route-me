//
//  AUOpenGISParser.m
//  Trail
//
//  Created by Karol Wojtaszek on 11-06-17.
//  Copyright 2011 AppUnite.com. All rights reserved.
//

#import "AUOpenGISParser.h"
#import "AUOpenGISCoordinate.h"

@implementation AUOpenGISParser

+ (NSNumber *) stringToNumber:(NSString *) string {
    return [NSNumber numberWithDouble:[string doubleValue]];
}

+ (NSArray *) parseLineString:(NSString *) lineString
{
    if (![[lineString substringToIndex:12] hasPrefix:@"LINESTRING("]) {
        NSLog(@"Can't find 'LINESTRING('");
        return nil;
    }    
    
    if (![lineString hasSuffix:@")"]) {
        NSLog(@"Can't find ')'");
        return nil;
    }
    
    NSString *coordinatesString = [lineString substringFromIndex:11];
    coordinatesString = [coordinatesString substringToIndex:[coordinatesString length] - 1];
    
    NSArray *coordinates = [coordinatesString componentsSeparatedByString: @","];
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:[coordinates count]];
    
    for (NSString *components in coordinates) {
        NSArray *coordArray = [components componentsSeparatedByString:@" "];
        if ([coordArray count] < 2 ) {
            NSLog(@"Unknown format with coordinates < 2");
            continue;
        }
        if ([coordArray count] > 4) {
            NSLog(@"Unknown format with coordinates > 4");
            continue;            
        }
        NSNumber *xCord = [AUOpenGISParser stringToNumber:[coordArray objectAtIndex:0]];
        NSNumber *yCord = [AUOpenGISParser stringToNumber:[coordArray objectAtIndex:1]];
         AUOpenGISCoordinate *location = [[AUOpenGISCoordinate alloc] initWith:xCord y:yCord];
        
        if ([coordArray count] > 2) {
            location.z = [AUOpenGISParser stringToNumber:[coordArray objectAtIndex:2]] ;
        }
        if ([coordArray count] > 3) {
            location.m = [AUOpenGISParser stringToNumber:[coordArray objectAtIndex:3]];
        }
        
        [retArray addObject:location];
    }

                                      
    return retArray;
}

@end
