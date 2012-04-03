//
//  RMTilesUpdateDelegate.h
//
//  Created by Olivier Brand.
//  Copyright 2008 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMLatLong.h"

@protocol RMTilesUpdateDelegate 

@required

- (void) regionUpdate: (RMSphericalTrapezium) region;

@end
