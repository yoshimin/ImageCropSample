//
//  YMNImageCropViewController.m
//  ImageCropSample
//
//  Created by 新谷　よしみ on 2014/08/13.
//  Copyright (c) 2014年 新谷　よしみ. All rights reserved.
//

#import "YMNImageCropViewController.h"

@interface YMNImageCropViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) YMNImageCropView *imageCropView;
@property (nonatomic, assign) CGFloat zoomRatio;

@end

@implementation YMNImageCropViewController

#pragma mark - Initialize -

- (instancetype)initWithImage:(UIImage*)image
{
    self = [super init];
    if (self) {
        CGRect toolbarFrame = CGRectMake(0.f, 0.f, self.view.bounds.size.width, 44.f);
        toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
        self.toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
        self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:self.toolbar];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(cancel)];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:nil];
        UIBarButtonItem *cropButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(crop)];
        [self.toolbar setItems:@[cancelButton, spacer, cropButton]];
        
        self.imageView = [[UIImageView alloc] initWithImage:image];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.imageView];
        
        self.imageCropView = [[YMNImageCropView alloc] initWithImage:image];
        [self.view addSubview:self.imageCropView];
    }
    return self;
}

#pragma mark - View Lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setImageViewFrame];
}


#pragma mark - Setter -

- (void)setCropMode:(YMNImageCropMode)cropMode
{
    self.imageCropView.cropMode = cropMode;
}

- (void)setCropRectAspectRatio:(CGFloat)cropRectAspectRatio
{
    self.imageCropView.cropRectAspectRatio = cropRectAspectRatio;
}


#pragma mark - Rotate -

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setImageViewFrame];
}

#pragma mark - View Appearance -

- (void)setImageViewFrame
{
    self.imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.toolbar.bounds.size.height);
    
    CGFloat imageAspect = self.imageView.image.size.height/self.imageView.image.size.width;
    CGFloat viewAspect = self.imageView.bounds.size.height/self.imageView.bounds.size.width;
    if (imageAspect > viewAspect) {
        self.zoomRatio = self.imageView.bounds.size.height/self.imageView.image.size.height;
    } else {
        self.zoomRatio = self.imageView.bounds.size.width/self.imageView.image.size.width;
    }
    CGSize imageSize = CGSizeMake(self.imageView.image.size.width*self.zoomRatio, self.imageView.image.size.height*self.zoomRatio);
    
    CGRect imageCropViewFrame;
    imageCropViewFrame.origin.x = (self.imageView.bounds.size.width - imageSize.width)*0.5;
    imageCropViewFrame.origin.y = (self.imageView.bounds.size.height - imageSize.height)*0.5;
    imageCropViewFrame.size = imageSize;
    
    self.imageCropView.frame = imageCropViewFrame;
}

#pragma mark - Action -

- (void)cancel
{
    if ([self.delegate respondsToSelector:@selector(imageCropViewControllerDidCancel:)]) {
		[self.delegate imageCropViewControllerDidCancel:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)crop
{
    CGImageRef srcImageRef = self.imageView.image.CGImage;
    
    CGRect cropRect = self.imageCropView.cropRect;
    cropRect.origin.x /= self.zoomRatio;
    cropRect.origin.y /= self.zoomRatio;
    cropRect.size.width /= self.zoomRatio;
    cropRect.size.height /= self.zoomRatio;
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(srcImageRef, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef];
    
    if ([self.delegate respondsToSelector:@selector(imageCropViewController:didFinishCroppingImage:)]) {
		[self.delegate imageCropViewController:self didFinishCroppingImage:croppedImage];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
