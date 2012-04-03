//
//  RMAUPath.h
//  MapView
//
//  Created by Jacek Marchwicki on 1/9/12.
//  Copyright (c) 2012 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMTrackPointsDAO.h"
#import "RMFoundation.h"

@class RMMapContents;

@interface RMAUPath  : RMMapLayer <RMTrackPointsDAODelegate>
{
	RMMapContents *_mapContents;
    RMTrackPointsDAO * _trackPointsDAO;
    
    CGFloat _lineWidth;
    CGMutablePathRef _path;
    CGFloat _scale;
    
    // Styles
    /*! Drawing mode of the path; Choices are
	 kCGPathFill,
	 kCGPathEOFill,
	 kCGPathStroke,
	 kCGPathFillStroke,
	 kCGPathEOFillStroke */
	CGPathDrawingMode _drawingMode;
	CGLineCap _lineCap;
	CGLineJoin _lineJoin;
	CGFloat _shadowBlur;
	CGSize _shadowOffset;
    UIColor *_lineColor;
	UIColor *_fillColor;
}

- (void) rescalePoints;

- (CGFloat) getMetersPerPixel;
- (RMProjectedPoint) getCenter;

- (id) initWithContents: (RMMapContents*)mapContents;

@property (nonatomic, strong) RMTrackPointsDAO * trackPointsDAO;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *fillColor;


@end
