//
//  ViewController.h
//  AWSDemo
//
//  Created by sanjeet on 4/15/16.
//  Copyright © 2016 sanjeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>
@interface ViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@property (nonatomic,strong)AWSS3TransferManagerUploadRequest *uploadRequest;
@property (nonatomic)UIImagePickerController *ImagePickerController;
@property (nonatomic)uint64_t filesize;
@property (nonatomic)uint64_t sizeUploaded;

@property (nonatomic,strong)UIView *loadingBg;
@property (nonatomic,strong)UIView *progressview;
@property (nonatomic,strong)UILabel *progressLabel;
@property (nonatomic) uint64_t amountUploaded;
@property (weak, nonatomic) IBOutlet UIImageView *SelectedImage;
- (IBAction)Gallery:(id)sender;
- (IBAction)Camera:(id)sender;
- (IBAction)UploadImage:(id)sender;
- (IBAction)DownloadImage:(id)sender;

@end

