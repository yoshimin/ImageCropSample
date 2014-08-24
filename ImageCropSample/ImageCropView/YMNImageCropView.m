//
//  YMNImageCropView.m
//  ImageCropSample
//
//  Created by 新谷　よしみ on 2014/08/13.
//  Copyright (c) 2014年 新谷　よしみ. All rights reserved.
//

#import "YMNImageCropView.h"

/// クロップの枠の移動か拡縮かのモード
typedef NS_ENUM(NSUInteger, YMNImageCropTouchMode) {
    YMNImageCropTouchModeNone,
    YMNImageCropTouchModeDrag,
    YMNImageCropTouchModeScaleFromTopLeft,
    YMNImageCropTouchModeScaleFromTopRight,
    YMNImageCropTouchModeScaleFromBottomLeft,
    YMNImageCropTouchModeScaleFromBottomRight
};

/// クロップの枠の拡縮するためのタップ範囲のサイズ
CGFloat const scaleTapAreaSize = 30;

/// クロップの枠の最小サイズ
CGFloat const cropFrameMinSize = 50;

@interface YMNImageCropView ()

@property (nonatomic, assign) YMNImageCropTouchMode touchMode;
@property (nonatomic, assign) CGPoint dragPoint;
@property (nonatomic, assign) CGRect topLeft;
@property (nonatomic, assign) CGRect topRight;
@property (nonatomic, assign) CGRect bottomLeft;
@property (nonatomic, assign) CGRect bottomRight;

@end

@implementation YMNImageCropView


#pragma mark - Initialize -

- (instancetype)initWithImage:(UIImage*)image
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8f];
        self.cropMode = YMNImageCropModeFlexible;
        self.cropRectAspectRatio = image.size.height/image.size.width;
    }
    return self;
}


#pragma mark - View Appearance -

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setDefaultCropRect];
    [self setNeedsDisplay];
}

- (void)setCropRectAspectRatio:(CGFloat)cropRectAspectRatio
{
    _cropRectAspectRatio = cropRectAspectRatio;
    [self setDefaultCropRect];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // クロップエリア
    CGContextRef squareContext = UIGraphicsGetCurrentContext();
    CGContextClearRect(squareContext, self.cropRect);
    
    // クロップエリアの枠線
    CGContextRef strokeContext = UIGraphicsGetCurrentContext();
    if (self.touchMode == YMNImageCropTouchModeNone || self.touchMode == YMNImageCropTouchModeDrag) {
        CGContextSetRGBStrokeColor(strokeContext, 226.f/255.f, 226.f/255.f, 226.f/255.f, 1.f);
    } else {
        CGContextSetRGBStrokeColor(strokeContext, 238.f/255.f, 169.f/255.f, 169.f/255.f, 1.f);
    }
    CGContextStrokeRectWithWidth(strokeContext, self.cropRect, 3.f);
    
    // クロップ枠の拡縮用タップ領域
    NSArray *scaleTapArea = @[[NSValue valueWithCGRect:self.topLeft],
                              [NSValue valueWithCGRect:self.topRight],
                              [NSValue valueWithCGRect:self.bottomLeft],
                              [NSValue valueWithCGRect:self.bottomRight]];
    
    // 拡縮用タップ領域を円形にする
    for (NSValue *value in scaleTapArea) {
        CGContextRef roundContext = UIGraphicsGetCurrentContext();
        if (self.touchMode == YMNImageCropTouchModeNone || self.touchMode == YMNImageCropTouchModeDrag) {
            CGContextSetRGBFillColor(roundContext, 226.f/255.f, 226.f/255.f, 226.f/255.f, 1.f);
            CGContextSetRGBStrokeColor(roundContext, 145.f/255.f, 145.f/255.f, 145.f/255.f, 1.f);
        } else {
            CGContextSetRGBFillColor(roundContext, 238.f/255.f, 169.f/255.f, 169.f/255.f, 1.f);
            CGContextSetRGBStrokeColor(roundContext, 198.f/255.f, 116.f/255.f, 116.f/255.f, 1.f);
        }
        CGContextFillEllipseInRect(roundContext, [value CGRectValue]);
        CGContextStrokeEllipseInRect(roundContext, [value CGRectValue]);
    }
}


#pragma mark - Touch Event Handling -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.dragPoint = [(UITouch*)[touches anyObject] locationInView:self];
    
    // 左上からの拡縮
    if (CGRectContainsPoint(self.topLeft, self.dragPoint)) {
        self.touchMode = YMNImageCropTouchModeScaleFromTopLeft;
    }
    // 右上からの拡縮
    else if (CGRectContainsPoint(self.topRight, self.dragPoint)) {
        self.touchMode = YMNImageCropTouchModeScaleFromTopRight;
    }
    // 左下からの拡縮
    else if (CGRectContainsPoint(self.bottomLeft, self.dragPoint)) {
        self.touchMode = YMNImageCropTouchModeScaleFromBottomLeft;
    }
    // 右下からの拡縮
    else if (CGRectContainsPoint(self.bottomRight, self.dragPoint)) {
        self.touchMode = YMNImageCropTouchModeScaleFromBottomRight;
    }
    // 透明部分のドラッグ
    else if (CGRectContainsPoint(self.cropRect, self.dragPoint)) {
        self.touchMode = YMNImageCropTouchModeDrag;
    }
    // 枠外のタップでは何もしない
    else {
        self.touchMode = YMNImageCropTouchModeNone;
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint newDragPoint = [(UITouch*)[touches anyObject] locationInView:self];
    
    switch (self.touchMode) {
        case YMNImageCropTouchModeNone:
            break;
            
        case YMNImageCropTouchModeDrag:
            [self moveCropFrame:newDragPoint];
            break;
            
        case YMNImageCropTouchModeScaleFromTopLeft:
        case YMNImageCropTouchModeScaleFromTopRight:
        case YMNImageCropTouchModeScaleFromBottomLeft:
        case YMNImageCropTouchModeScaleFromBottomRight:
            [self scaleCropFrame:newDragPoint];
            break;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchMode = YMNImageCropTouchModeNone;
    [self setNeedsDisplay];
}


#pragma mark - Touch Event Action -

- (void)moveCropFrame:(CGPoint)newDragPoint
{
    CGRect newCropRect = self.cropRect;
    newCropRect.origin.x += (newDragPoint.x - self.dragPoint.x);
    newCropRect.origin.y += (newDragPoint.y - self.dragPoint.y);
    
    newCropRect = [self adjustedFrameToSetInView:newCropRect];
    
    self.cropRect = newCropRect;
    [self setNeedsDisplay];
    
    self.dragPoint = newDragPoint;
}

- (void)scaleCropFrame:(CGPoint)newDragPoint
{
    CGRect newCropRect = self.cropRect;
    
    CGFloat obliqueDistance = sqrtf(pow((self.dragPoint.x - newDragPoint.x), 2) + pow((self.dragPoint.y - newDragPoint.y), 2));
    
    switch (self.cropMode) {
        case YMNImageCropModeFlexible:
            if (self.touchMode == YMNImageCropTouchModeScaleFromTopLeft) {
                newCropRect.size.width += (self.dragPoint.x - newDragPoint.x);
                newCropRect.size.height += (self.dragPoint.y - newDragPoint.y);
                // 右側からwidthが変更される場合はx座標も移動させる
                newCropRect.origin.x += (newDragPoint.x - self.dragPoint.x);
                // 上側からheightが変更される場合はy座標も移動させる
                newCropRect.origin.y += (newDragPoint.y - self.dragPoint.y);
                
            } else if (self.touchMode == YMNImageCropTouchModeScaleFromTopRight) {
                newCropRect.size.width += (newDragPoint.x - self.dragPoint.x);
                newCropRect.size.height += (self.dragPoint.y - newDragPoint.y);
                newCropRect.origin.y += (newDragPoint.y - self.dragPoint.y);
                
            }  else if (self.touchMode == YMNImageCropTouchModeScaleFromBottomLeft) {
                newCropRect.size.width += (self.dragPoint.x - newDragPoint.x);
                newCropRect.size.height += (newDragPoint.y - self.dragPoint.y);
                newCropRect.origin.x += (newDragPoint.x - self.dragPoint.x);
                
            }  else if (self.touchMode == YMNImageCropTouchModeScaleFromBottomRight) {
                newCropRect.size.width += (newDragPoint.x - self.dragPoint.x);
                newCropRect.size.height += (newDragPoint.y - self.dragPoint.y);
            }
            break;
            
        case YMNImageCropModeFixedAspect:
            
            if (self.touchMode == YMNImageCropTouchModeScaleFromTopLeft ||
                self.touchMode == YMNImageCropTouchModeScaleFromBottomLeft) {
                if (newDragPoint.x > self.dragPoint.x) {
                    obliqueDistance *= -1;
                }
                
            } else if (self.touchMode == YMNImageCropTouchModeScaleFromTopRight ||
                       self.touchMode == YMNImageCropTouchModeScaleFromBottomRight) {
                if (newDragPoint.x < self.dragPoint.x) {
                    obliqueDistance *= -1;
                }
            }
            
            newCropRect.size.width += obliqueDistance;
            newCropRect.size.height *= newCropRect.size.width/self.cropRect.size.width;
            
            // クロップ枠を拡縮した場合は枠の中心座標が移動しないように枠のoriginを調整する
            // クロップ枠がすでに最小サイズのときはわく全体が動いてしまうのでoriginの調整をしない
            if (newCropRect.size.width > [self cropFrameMinSizeWidth]) {
                newCropRect.origin.x -= obliqueDistance*0.5;
                newCropRect.origin.y -= obliqueDistance*0.5;
            }
            
            break;
    }
    
    
    newCropRect = [self adjustedFrameToSetInView:newCropRect];
    
    self.cropRect = newCropRect;
    [self setNeedsDisplay];
    
    self.dragPoint = newDragPoint;
}

- (void)setDefaultCropRect
{
    self.cropRect = CGRectMake((self.bounds.size.width - [self cropFrameMaxSizeWidth])*0.5,
                               (self.bounds.size.height - [self cropFrameMaxSizeHeight])*0.5,
                               [self cropFrameMaxSizeWidth],
                               [self cropFrameMaxSizeHeight]);
}

- (void)setCropRect:(CGRect)cropRect
{
    _cropRect = cropRect;
    
    self.topLeft = CGRectMake(CGRectGetMinX(self.cropRect) - scaleTapAreaSize*0.5,
                              CGRectGetMinY(self.cropRect) - scaleTapAreaSize*0.5,
                              scaleTapAreaSize,
                              scaleTapAreaSize);
    self.topRight = CGRectMake(CGRectGetMaxX(self.cropRect) - scaleTapAreaSize*0.5,
                               CGRectGetMinY(self.cropRect) - scaleTapAreaSize*0.5,
                               scaleTapAreaSize,
                               scaleTapAreaSize);
    self.bottomLeft = CGRectMake(CGRectGetMinX(self.cropRect) - scaleTapAreaSize*0.5,
                                 CGRectGetMaxY(self.cropRect) - scaleTapAreaSize*0.5,
                                 scaleTapAreaSize,
                                 scaleTapAreaSize);
    self.bottomRight = CGRectMake(CGRectGetMaxX(self.cropRect) - scaleTapAreaSize*0.5,
                                  CGRectGetMaxY(self.cropRect) - scaleTapAreaSize*0.5,
                                  scaleTapAreaSize,
                                  scaleTapAreaSize);
}


#pragma mark - Frame Calculate -

// 枠のサイズが最小最大値を越えないように調整する
- (CGRect)adjustedFrameToSetInView:(CGRect)frame
{
    // 枠のwidthが最小サイズを下回る場合はwidthを縮小させない
    if (frame.size.width < [self cropFrameMinSizeWidth]) {
        frame.size.width = [self cropFrameMinSizeWidth];
    }
    // 枠のwidthが画面サイズを上回る場合はwidthを拡大させない
    if (frame.size.width > [self cropFrameMaxSizeWidth]) {
        frame.size.width = [self cropFrameMaxSizeWidth];
    }
    
    // 枠のheightが最小サイズを下回る場合はheightを縮小させない
    if (frame.size.height < [self cropFrameMinSizeHeight]) {
        frame.size.height = [self cropFrameMinSizeHeight];
    }
    // 枠のheightが画面サイズを上回る場合はheightを拡大させない
    if (frame.size.height > [self cropFrameMaxSizeHeight]) {
        frame.size.height = [self cropFrameMaxSizeHeight];
    }
    
    // 枠の右端x座標が画面外へはみ出てしまわないように調整する
    if (CGRectGetMinX(frame) < CGRectGetMinX(self.bounds)) {
        frame.origin.x = CGRectGetMinX(self.bounds);
    }
    if (CGRectGetMaxX(frame) > CGRectGetMaxX(self.bounds)) {
        frame.origin.x = CGRectGetMaxX(self.bounds) - frame.size.width;
    }
    
    // 枠の下端y座標が画面外へはみ出てしまわないように調整する
    if (CGRectGetMinY(frame) < CGRectGetMinY(self.bounds)) {
        frame.origin.y = CGRectGetMinY(self.bounds);
    }
    if (CGRectGetMaxY(frame) > CGRectGetMaxY(self.bounds)) {
        frame.origin.y = CGRectGetMaxY(self.bounds) - frame.size.height;
    }
    return frame;
}

- (CGFloat)cropFrameMinSizeWidth
{
    if (self.frame.size.width > self.frame.size.height) {
        return cropFrameMinSize;
    }
    
    return cropFrameMinSize / self.cropRectAspectRatio;
}

- (CGFloat)cropFrameMinSizeHeight
{
    if (self.frame.size.height > self.frame.size.width) {
        return cropFrameMinSize;
    }
    
    return cropFrameMinSize / self.cropRectAspectRatio;
}

- (CGFloat)cropFrameMaxSizeWidth
{
    if (self.cropMode == YMNImageCropModeFlexible) {
        return self.bounds.size.width;
    }
    
    CGFloat viewAspect = self.bounds.size.height/self.bounds.size.width;

    // クロップ枠の縦横比がimageCropViewの縦横比よりも小さい時はimageCropViewの横幅が最大サイズ
    if (self.cropRectAspectRatio <= viewAspect) {
        return self.bounds.size.width;
    }
    
    return self.bounds.size.height / self.cropRectAspectRatio;
}

- (CGFloat)cropFrameMaxSizeHeight
{
    if (self.cropMode == YMNImageCropModeFlexible) {
        return self.bounds.size.height;
    }
    
    CGFloat viewAspect = self.bounds.size.height/self.bounds.size.width;
    
    // クロップ枠の縦横比がimageCropViewの縦横比よりも大きい時はimageCropViewの縦幅が最大サイズ
    if (self.cropRectAspectRatio >= viewAspect) {
        return self.bounds.size.height;
    }
    
    return self.bounds.size.width / self.cropRectAspectRatio;
}

@end
