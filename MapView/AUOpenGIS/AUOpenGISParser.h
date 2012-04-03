//
//  AUOpenGISParser.h
//  Trail
//
//  Created by Karol Wojtaszek on 11-06-17.
//  Copyright 2011 AppUnite.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AUOpenGISParser : NSObject {
    
}

+ (NSArray *) parseLineString:(NSString *) lineString;

@end
