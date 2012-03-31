//
//  TrackPointsDAO.h
//  trail
//
//  Created by Jacek Marchwicki on 12/14/11.
//  Copyright (c) 2011 AppUnite.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUOpenGISCoordinate.h"
#import <RMMarker.h>

@class RMTrackPointsDAO;

@protocol RMTrackPointsDAODelegate <NSObject>
- (void) trackPointsDAONewData: (RMTrackPointsDAO *) trackPointDAO;
- (void) setStartingMarker: (RMMarker *)marker atLatLong:(CLLocationCoordinate2D)location;
- (void) setStopMarker: (RMMarker *)marker atLatLong:(CLLocationCoordinate2D)location;
- (void) removeMarkers:(NSArray *)markers;
@end

@interface RMTrackPointsDAO : NSObject {
    NSMutableArray *_trackPoints;
    
    NSMutableArray *_delegates;
    RMMarker *_startingMarker;
    RMMarker *_stopMarker;
    
    CLLocationCoordinate2D _startingLocation;
    CLLocationCoordinate2D _stopLocation;
}

+ (RMTrackPointsDAO *)sharedRMTrackPointsDAO;

- (void) clearPoints;
- (void) addPoint:(AUOpenGISCoordinate *) coordinate;
- (void) addDelegate: (id<RMTrackPointsDAODelegate>) delegate;
- (void) removeDelegate: (id<RMTrackPointsDAODelegate>) delegate;
- (void) loadFromString: (NSString*) data;
- (NSArray *) trackPoints;

@property (nonatomic, strong) RMMarker *startingMarker;
@property (nonatomic, strong) RMMarker *stopMarker;
@property (nonatomic, assign) CLLocationCoordinate2D startingLocation;
@property (nonatomic, assign) CLLocationCoordinate2D stopLocation;

- (void) setStartingPoint:(CLLocationCoordinate2D)location;
- (void) setStopPoint:(CLLocationCoordinate2D)location;

@end
