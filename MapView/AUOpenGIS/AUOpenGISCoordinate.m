//
//  AUOpenGISCoordinate.m
//  Trail
//
//  Created by Karol Wojtaszek on 11-06-17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AUOpenGISCoordinate.h"


@implementation AUOpenGISCoordinate

@synthesize x = _x;
@synthesize y = _y;
@synthesize z = _z;
@synthesize m = _m;

- (id) initWith:(NSNumber *)xCord y:(NSNumber *)yCord
{
    self = [super init];
    if (self) {
        self.x = xCord;
        self.y = yCord;
    }
    return self;
}

- (id) initWith:(NSNumber *)xCord y:(NSNumber *)yCord z:(NSNumber *)zCord
{
    self = [self initWith:xCord y:yCord];
    self.z = zCord;
    
    return self;
}

- (id) initWith:(NSNumber *)xCord y:(NSNumber *)yCord z:(NSNumber *)zCord m:(NSNumber *)mCord
{
    self = [self initWith:xCord y:yCord z:zCord];
    self.m = mCord;
    
    return self;
}

- (CLLocationCoordinate2D)coorinate {
    CLLocationCoordinate2D ret;
    ret.latitude = [_y doubleValue];
    ret.longitude = [_x doubleValue];
    return ret;
}

- (void)dealloc {
    [_x retain];
    [_y retain];
    [_z retain];
    [_m retain];
}

@end
