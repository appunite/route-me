///
//  RMCircle.m
//
// Copyright (c) 2008-2010, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "RMLocationMarker.h"
#import "RMMapContents.h"
#import "RMProjection.h"
#import "RMMercatorToScreenProjection.h"
#import "RMPixel.h"

#define kDefaultLineWidth 10
#define kDefaultLineColor [UIColor blackColor]
#define kDefaultFillColor [UIColor blueColor]

@interface RMLocationMarker ()

- (void)updateCirclePath;

@end


@implementation RMLocationMarker

@synthesize projectedLocation=_projectedLocation;
@synthesize lineColor=_lineColor;
@synthesize fillColor=_fillColor;
@synthesize radiusInMeters=_radiusInMeters;
@synthesize lineWidthInPixels=_lineWidthInPixels;
@synthesize enableDragging = _enableDragging;
@synthesize enableRotation = _enableRotation;

- (id)initWithContents:(RMMapContents*)aContents radiusInMeters:(CGFloat)newRadiusInMeters latLong:(RMLatLong)newLatLong {
	self = [super init];
	
	if (self) {
		_markerDotImage = [UIImage imageNamed:@"marker-dot"];
		_mapContents = aContents;
		_radiusInMeters = newRadiusInMeters;
		_latLong = newLatLong;
		_projectedLocation = [[_mapContents projection] latLongToPoint:newLatLong];
		[self setPosition:[[_mapContents mercatorToScreenProjection] projectXYPoint:_projectedLocation]];
//		DLog(@"Position: %f, %f", [self position].x, [self position].y);
		
		_lineWidthInPixels = kDefaultLineWidth;
		_lineColor = kDefaultLineColor;
		_fillColor = kDefaultFillColor;
		_enableRotation = NO;
        _enableDragging = NO;
        _headingVisible = NO;
        _magneticHeading = 0.0f;
		
		[self updateCirclePath];
	}
	
	return self;
}

- (void)dealloc {
	[_lineColor release];
	_lineColor = nil;
	[_fillColor release];
	_fillColor = nil;
	[super dealloc];
    [_markerDotImage release];
    _markerDotImage = nil;
}

#pragma mark -



- (CGImageRef) createMaskTriangle: (CGRect) rect {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef maskContext = CGBitmapContextCreate (NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);    
    
    
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(maskContext, rect);
    
    // Draw the text upside-down
    CGContextSaveGState(maskContext);
    
    CGContextBeginPath (maskContext);
    CGContextMoveToPoint(maskContext, CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGContextAddLineToPoint(maskContext, CGRectGetMinX(rect) + CGRectGetWidth(rect) * 0.2, CGRectGetMinY(rect));
    CGContextAddLineToPoint(maskContext, CGRectGetMaxX(rect) - CGRectGetWidth(rect) * 0.2, CGRectGetMinY(rect));
    CGContextClosePath(maskContext);
    
    
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillPath(maskContext);
    
    CGContextRestoreGState(maskContext);
    
    
    
    CGImageRef alphaMask = CGBitmapContextCreateImage(maskContext);
    CGContextRelease(maskContext);
    
    return alphaMask;
}

- (CGImageRef) createCircleMask: (CGRect) rect {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef maskContext = CGBitmapContextCreate (NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);    
    
    
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(maskContext, rect);
    
    // Draw the text upside-down
    CGContextSaveGState(maskContext);
    
    CGContextAddEllipseInRect(maskContext, rect);
    
    
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillPath(maskContext);
    
    CGContextRestoreGState(maskContext);
    
    
    
    CGImageRef alphaMask = CGBitmapContextCreateImage(maskContext);
    CGContextRelease(maskContext);
    
    return alphaMask;
}

- (CGImageRef) createImageMaskFromImage: (CGImageRef) image {
    return CGImageMaskCreate(CGImageGetWidth(image)
                             , CGImageGetHeight(image)
                             , CGImageGetBitsPerComponent(image)
                             , CGImageGetBitsPerPixel(image)
                             , CGImageGetBytesPerRow(image)
                             ,  CGImageGetDataProvider(image)
                             , NULL
                             , false);
}

- (CGGradientRef) createGradient {
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 3;
    CGFloat locations[3] = { 0.0, 0.2, 0.7 };
    CGFloat components[12] = { 0xfe/255.0, 0xfe/255.0, 0xfe/255.0, 0.9,  // Start color
        0xfe/255.0, 0xfe/255.0, 0xfe/255.0, 0.9,  // Middle color
        0xfe/255.0, 0xfe/255.0, 0xfe/255.0, 0.0 }; // End color
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    CGColorSpaceRelease(myColorspace);
    return myGradient;
}

- (void) paintRadialGradient: (CGContextRef) ctx rectangle: (CGRect) rectangle {
    
    CGPoint myStartPoint, myEndPoint;
    CGFloat myStartRadius, myEndRadius;
    CGGradientRef myGradient = [self createGradient];
    myStartPoint.x = CGRectGetMidX(rectangle);
    myStartPoint.y = CGRectGetMidY(rectangle);
    myEndPoint.x = CGRectGetMidX(rectangle);
    myEndPoint.y = CGRectGetMidY(rectangle);
    myStartRadius = 0.0;
    myEndRadius = CGRectGetHeight(rectangle)/2.0;
    CGContextDrawRadialGradient (ctx, myGradient, myStartPoint,
                                 myStartRadius, myEndPoint, myEndRadius,
                                 kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(myGradient);
    
}

- (void)updateCirclePath {
	
	CGFloat latRadians = _latLong.latitude * M_PI / 180.0f;
	_pixelRadius = _radiusInMeters / cos(latRadians) / [_mapContents metersPerPixel];
    //	DLog(@"Pixel Radius: %f", pixelRadius);
    CGFloat pixelRadius = _pixelRadius;
	if (pixelRadius < 30.0)
        pixelRadius = 30.0f;
	CGRect rectangle = CGRectMake(self.position.x - pixelRadius, 
								  self.position.y - pixelRadius, 
								  (pixelRadius * 2), 
								  (pixelRadius * 2));
	
	CGFloat offset = floorf(-_lineWidthInPixels / 2.0f) - 2;
    //	DLog(@"Offset: %f", offset);
	CGRect newBoundsRect = CGRectInset(rectangle, offset, offset);
	[super setBounds:newBoundsRect];
    [self setNeedsDisplay];
}

- (void) drawAccurracyCircleInContext: (CGContextRef) ctx {
    
    CGRect rectangle = CGRectInset(self.bounds, 2.0f, 2.0f);
    
    
    
    CGContextSaveGState(ctx);
    
    CGContextAddEllipseInRect(ctx, rectangle);
    
    CGContextSetLineWidth(ctx, 1.0f);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0xb2/255.0 green:0xbe/255.0 blue:0xd4/255.0 alpha:0.5f].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0x19/255.0 green:0x72/255.0 blue:0xe9/255.0 alpha:0.5f].CGColor);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    CGContextRestoreGState(ctx);
    
    if (_headingVisible) {
        
        CGRect rect = CGRectMake(0.0, 0.0, CGRectGetWidth(rectangle), CGRectGetHeight(rectangle));
        
        CGImageRef triangleImage= [self createMaskTriangle:rect];
        
        CGImageRef triangleMask = [self createImageMaskFromImage:triangleImage];
        
        CGImageRef circleImage = [self createCircleMask:rect];
        
        CGImageRef circleMask = [self createImageMaskFromImage:circleImage];
        
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, CGRectGetMidX(rectangle), CGRectGetMidY(rectangle));
        CGContextRotateCTM(ctx, _magneticHeading);
        CGContextTranslateCTM(ctx, -CGRectGetMidX(rectangle), -CGRectGetMidY(rectangle));
        CGContextSaveGState(ctx);
        CGContextClipToMask(ctx, rectangle, triangleMask);
        CGContextClipToMask(ctx, rectangle, circleMask);
        
        [self paintRadialGradient:ctx rectangle:rectangle];
        
        CGContextRestoreGState(ctx);
        
        CGContextRestoreGState(ctx);
        
        CGImageRelease(triangleMask);
        CGImageRelease(triangleImage);
        
        CGImageRelease(circleMask);
        CGImageRelease(circleImage);
    }

    
}

- (void) drawDotInContext: (CGContextRef)ctx {
    
    CGFloat pixelRadius = 12.0f/2.0f;
    CGRect rectangle = CGRectMake(CGRectGetMidX(self.bounds) - pixelRadius, 
                                 CGRectGetMidY(self.bounds) - pixelRadius, 
                                 (pixelRadius * 2), 
                                 (pixelRadius * 2));
    
    CGContextSaveGState(ctx);
    
    CGContextDrawImage(ctx, rectangle, _markerDotImage.CGImage);
    CGContextRestoreGState(ctx);
}

- (void)drawInContext:(CGContextRef)ctx {
    CGContextSetAllowsAntialiasing(ctx, YES);
    
    if (_pixelRadius >= 20.0)
    {
        [self drawAccurracyCircleInContext:ctx];
    }
    [self drawDotInContext:ctx];
}

#pragma mark Accessors

- (void)setProjectedLocation:(RMProjectedPoint)newProjectedLocation {
	_projectedLocation = newProjectedLocation;
	
	[self setPosition:[[_mapContents mercatorToScreenProjection] projectXYPoint:_projectedLocation]];
}

- (void)setLineColor:(UIColor*)newLineColor {
	if (_lineColor != newLineColor) {
		[_lineColor release];
		_lineColor = [newLineColor retain];
		[self updateCirclePath];
	}
}

- (void)setFillColor:(UIColor*)newFillColor {
	if (_fillColor != newFillColor) {
		[_fillColor release];
		_fillColor = [newFillColor retain];
		[self updateCirclePath];
	}
}

- (void)setRadiusInMeters:(CGFloat)newRadiusInMeters {
	_radiusInMeters = newRadiusInMeters;
	[self updateCirclePath];
}

- (void)setLineWidthInPixels:(CGFloat)newLineWidthInPixels {
	_lineWidthInPixels = newLineWidthInPixels;
	[self updateCirclePath];
}

#pragma mark Map Movement and Scaling

- (void)moveBy: (CGSize) delta
{
    [self setPosition:[[_mapContents mercatorToScreenProjection] projectXYPoint:_projectedLocation]];
}

- (id<CAAction>)actionForKey:(NSString *)key
{
	if ([key isEqualToString:@"position"]
		|| [key isEqualToString:@"bounds"])
		return nil;
	
	else return [super actionForKey:key];
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) pivot
{
    [self setPosition:[[_mapContents mercatorToScreenProjection] projectXYPoint:_projectedLocation]];
    [self updateCirclePath];
//	self.bounds = newRect;
}

- (void)setBounds:(CGRect)bounds {
    [self updateCirclePath];
}

- (void) setPosition:(CGPoint)position {
    [super setPosition:position];
}

- (void)moveToLatLong:(RMLatLong)newLatLong {
	_latLong = newLatLong;
	[self setProjectedLocation:[[_mapContents projection] latLongToPoint:newLatLong]];
	[self setPosition:[[_mapContents mercatorToScreenProjection] projectXYPoint:_projectedLocation]];
	NSLog(@"Position: %f, %f", [self position].x, [self position].y);
}

- (void)setHeadingVisible:(BOOL)headingVisible {
    _headingVisible = headingVisible;
    [self setNeedsDisplay];
}

- (void)setMagneticHeading:(CLLocationDirection)magneticHeading {
    _magneticHeading = magneticHeading;
    [self setNeedsDisplay];
}

- (BOOL)headingVisible {
    return _headingVisible;
}

- (CLLocationDirection)magneticHeading {
    return _magneticHeading;
}

@end
