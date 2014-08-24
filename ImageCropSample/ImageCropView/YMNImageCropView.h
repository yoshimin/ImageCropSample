//
//  YMNImageCropView.h
//  ImageCropSample
//
//  Created by 新谷　よしみ on 2014/08/13.
//  Copyright (c) 2014年 新谷　よしみ. All rights reserved.
//

#import <UIKit/UIKit.h>

/// クロップの枠の拡縮の仕方
typedef NS_ENUM(NSUInteger, YMNImageCropMode) {
    /// 枠のアスペクト比は自由
    YMNImageCropModeFlexible,
    /// 枠のアスペクト比は固定
    YMNImageCropModeFixedAspect
};

@interface YMNImageCropView : UIView

@property (nonatomic, assign) YMNImageCropMode cropMode;
/// クロップの枠のアスペクト比（縦/横）
@property (nonatomic, assign) CGFloat cropRectAspectRatio;
/// クロップ枠のフレーム
@property (nonatomic, readonly) CGRect cropRect;

- (instancetype)initWithImage:(UIImage*)image;

@end
