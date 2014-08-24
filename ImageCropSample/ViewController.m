//
//  ViewController.m
//  ImageCropSample
//
//  Created by 新谷　よしみ on 2014/08/13.
//  Copyright (c) 2014年 新谷　よしみ. All rights reserved.
//

#import "ViewController.h"
#import "YMNImageCropViewController.h"

@interface ViewController ()  <UINavigationControllerDelegate, UIImagePickerControllerDelegate, YMNImageCropViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) YMNImageCropViewController *imageCropViewController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)chooseImage:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)saveImage:(id)sender
{
    if (!self.imageView.image) {
        return;
    }
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil);
    [[[UIAlertView alloc] initWithTitle:nil
                               message:@"Saved!"
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil] show];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.imageCropViewController = [[YMNImageCropViewController alloc] initWithImage:image];
    self.imageCropViewController.cropMode = YMNImageCropModeFixedAspect;
    self.imageCropViewController.cropRectAspectRatio = 1.f;
    self.imageCropViewController.delegate = self;
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 if (!image) {
                                     return;
                                 }
                                 [self presentViewController:self.imageCropViewController animated:NO completion:nil];
                             }];
    
}

- (void)imageCropViewController:(UIViewController *)controller didFinishCroppingImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (void)imageCropViewControllerDidCancel:(UIViewController *)controller
{
    
}

@end
