//
//  AUOpenGISCoordinate.h
//  Trail
//
//  Created by Karol Wojtaszek on 11-06-17.
//  Copyright 2011 AppUnite.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface AUOpenGISCoordinate : NSObject {
    NSNumber *_x;
    NSNumber *_y;
    NSNumber *_z;
    NSNumber *_m;
}

@property (nonatomic, strong) NSNumber *x;
@property (nonatomic, strong) NSNumber *y;
@property (nonatomic, strong) NSNumber *z;
@property (nonatomic, strong) NSNumber *m;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D coorinate;

- (id) initWith:(NSNumber *)xCord y:(NSNumber *)yCord;
- (id) initWith:(NSNumber *)xCord y:(NSNumber *)yCord z:(NSNumber *)zCord;
- (id) initWith:(NSNumber *)xCord y:(NSNumber *)yCord z:(NSNumber *)zCord m:(NSNumber *)mCord;

@end
