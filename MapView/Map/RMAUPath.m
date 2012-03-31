
//
//  RMAUPath.m
//  MapView
//
//  Created by Jacek Marchwicki on 1/9/12.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import "RMAUPath.h"
#import "RMMapView.h"
#import "RMMapContents.h"
#import "RMMercatorToScreenProjection.h"
#import "RMPixel.h"
#import "RMProjection.h"

@implementation RMAUPath

@synthesize lineWidth = _lineWidth;
@synthesize lineColor = _lineColor;
@synthesize fillColor = _fillColor;

- (void) rescalePoints {
    
    RMMercatorToScreenProjection * projection = [_mapContents mercatorToScreenProjection];
    
    _scale = 1.0f / [projection metersPerPixel];
    
    RMProjectedRect projectedBounds = [projection projectedBounds];
    CGRect bounds = CGRectMake(projectedBounds.origin.easting, -projectedBounds.origin.northing - projectedBounds.size.height, projectedBounds.size.width, projectedBounds.size.height);
    
    bounds = RMScaleCGRectAboutPoint(bounds, _scale, CGPointZero);

    @synchronized(self) {
        CGRect boundsInMercators = CGPathGetBoundingBox(_path);
        boundsInMercators = RMScaleCGRectAboutPoint(boundsInMercators, _scale, CGPointZero);
        //    boundsInMercators = CGRectInset(boundsInMercators, _lineWidth * (1.0 / _scale), _lineWidth * (1.0 / _scale));
        CGPoint position = CGPointMake(CGRectGetMidX(boundsInMercators) - CGRectGetMinX(bounds),CGRectGetMidY(boundsInMercators) - CGRectGetMinY(bounds));
        [super setBounds:boundsInMercators];
        
        [self setPosition:position];
    }
    [self setNeedsDisplay];
}

- (void) getNewTrackPoints {
    @synchronized (self) {
        if (!CGPathIsEmpty(_path)) {
            CGPathRelease(_path);
            _path = CGPathCreateMutable();
        }
    }
    BOOL first = YES;
    
    for (AUOpenGISCoordinate* trackPoint in _trackPointsDAO.trackPoints) {
        RMLatLong point;
		point.latitude = [trackPoint.y doubleValue];
		point.longitude = [trackPoint.x doubleValue];
        RMProjectedPoint mercator = [[_mapContents projection]
                                     latLongToPoint:point];
        if (first) {
            first = NO;
            CGPathMoveToPoint(_path, NULL, mercator.easting, -mercator.northing);
        } else {
            CGPathAddLineToPoint(_path, NULL, mercator.easting, -mercator.northing);
        }
	}
    [self rescalePoints];
}


- (void)setTrackPointsDAO:(RMTrackPointsDAO *)trackPointsDAO {
    if (_trackPointsDAO != nil) {
        [_trackPointsDAO removeDelegate:self];
        _trackPointsDAO = nil;
    }
    _trackPointsDAO = trackPointsDAO;
    if (trackPointsDAO == nil)
        return;
    [trackPointsDAO addDelegate:self];
    [self getNewTrackPoints];
    
}

- (RMTrackPointsDAO *)trackPointsDAO {
    return _trackPointsDAO;
}

- (void)trackPointsDAONewData:(RMTrackPointsDAO *)trackPointDAO {
    assert(_trackPointsDAO == trackPointDAO);
    [self getNewTrackPoints];
}

- (void)setStartingMarker:(RMMarker *)marker atLatLong:(CLLocationCoordinate2D)location {
    
}

- (void)setStopMarker:(RMMarker *)marker atLatLong:(CLLocationCoordinate2D)location {
    
}

- (void)removeMarkers:(NSArray *)markers {
    
}

- (void)drawInContext:(CGContextRef)ctx
{
    @synchronized(self) {
    if (CGPathIsEmpty(_path))
        return;
    CGRect boundsInMercators = CGPathGetBoundingBox(_path);
    
//    boundsInMercators = CGRectInset(boundsInMercators, -_lineWidth * (1.0 / _scale), -_lineWidth * (1.0 / _scale));
    CGFloat scale = CGRectGetWidth(self.bounds) / CGRectGetWidth(boundsInMercators);
    
//    CGRect rect = CGContextGetClipBoundingBox(ctx);
	
	CGFloat scaledLineWidth = _lineWidth * (1.0 / scale);
    
	CGContextScaleCTM(ctx, scale, scale);
	
	CGContextBeginPath(ctx);
	CGContextAddPath(ctx, _path); 
	
	CGContextSetLineWidth(ctx, scaledLineWidth);
	CGContextSetLineCap(ctx, _lineCap);
	CGContextSetLineJoin(ctx, _lineJoin);	
	CGContextSetStrokeColorWithColor(ctx, [_lineColor CGColor]);
	CGContextSetFillColorWithColor(ctx, [_fillColor CGColor]);
	CGContextSetShadow(ctx, _shadowOffset, _shadowBlur);
	
	CGContextDrawPath(ctx, _drawingMode);
    }
}

- (void)zoomByFactor:(float)zoomFactor near:(CGPoint)center {
//    [_lock lock];
    [super zoomByFactor:zoomFactor near:center];
    //[self rescalePoints];
//    [_lock unlock];
}

- (void)setBounds:(CGRect)bounds {
    //[super setBounds:bounds];
    [self rescalePoints];
}

- (void)moveBy:(CGSize)delta {
    [super moveBy:delta];
}

#pragma mark - public methods

- (RMProjectedPoint)getCenter {
    CGRect boundsInMercators = CGPathGetBoundingBox(_path);
    RMProjectedRect projectedRect = RMMakeProjectedRect(boundsInMercators.origin.x, -boundsInMercators.origin.y - boundsInMercators.size.height, boundsInMercators.size.width, boundsInMercators.size.height);
    return RMMakeProjectedPoint(RMProjectedRectGetMidEasting(projectedRect), RMProjectedRectGetMidNorthing(projectedRect));
}

- (CGFloat)getMetersPerPixel {
    CGRect boundsInMercators = CGPathGetBoundingBox(_path);
    if (CGPathIsEmpty(_path))
        return 0.0f;
    RMProjectedRect projectedRect = RMMakeProjectedRect(boundsInMercators.origin.x, -boundsInMercators.origin.y - boundsInMercators.size.height, boundsInMercators.size.width, boundsInMercators.size.height);
    CGRect screenBounds = [_mapContents.mercatorToScreenProjection screenBounds];
    float scaleX = projectedRect.size.width / screenBounds.size.width;
	float scaleY = projectedRect.size.height / screenBounds.size.height;
    
    return MAX(scaleX, scaleY) * 1.2;
}

#pragma mark - init/dealoc

- (id) initWithContents: (RMMapContents*)mapContents
{
	self = [super init];
    if (self) {
        self.contentsScale = [[UIScreen mainScreen] scale];
        // styles
        _lineWidth = 2.0;
        _lineJoin = kCGLineJoinMiter;
        _lineCap = kCGLineCapButt;
        _lineColor = [UIColor colorWithRed:255.0f/255.0f green:25.0f/255.0f blue:0.0f/255.0f alpha:0.8];
//        _lineColor = [UIColor blueColor];
        _fillColor = [UIColor redColor];
        _shadowBlur = 0.0;
        _shadowOffset = CGSizeMake(0, 0);
        _drawingMode = kCGPathStroke;
        
        _mapContents = mapContents;
        _path = CGPathCreateMutable();
        
//        self.levelsOfDetail = 30;
//        self.levelsOfDetailBias = 30;
    }
    return self;
}

- (void)dealloc {
    CGPathRelease(_path);
    if (_trackPointsDAO != nil) {
        [_trackPointsDAO removeDelegate:self];
        _trackPointsDAO = nil;
    }
}

@end
