//
//  YMNImageCropViewController.h
//  ImageCropSample
//
//  Created by 新谷　よしみ on 2014/08/13.
//  Copyright (c) 2014年 新谷　よしみ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMNImageCropView.h"

@protocol YMNImageCropViewControllerDelegate <NSObject>

- (void)imageCropViewController:(UIViewController* )controller didFinishCroppingImage:(UIImage *)image;
- (void)imageCropViewControllerDidCancel:(UIViewController *)controller;

@end

@interface YMNImageCropViewController : UIViewController

@property (nonatomic, assign) YMNImageCropMode cropMode;
/// クロップの枠のアスペクト比（縦/横）
@property (nonatomic, assign) CGFloat cropRectAspectRatio;
@property (nonatomic,assign) id <YMNImageCropViewControllerDelegate> delegate;

- (instancetype)initWithImage:(UIImage*)image;

@end
