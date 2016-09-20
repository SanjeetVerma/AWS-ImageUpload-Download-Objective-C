//
//  ViewController.m
//  AWSDemo
//
//  Created by sanjeet on 4/15/16.
//  Copyright © 2016 sanjeet. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//Access Key ID:AKIAJZJZZXLEKNB6J5PA
//Secret Access Key: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
//Bucket name:-  s3-ios-test

- (IBAction)Gallery:(id)sender {
    
    self.ImagePickerController = [[UIImagePickerController alloc]init];
    self.ImagePickerController.delegate = self;
    self.ImagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:self.ImagePickerController animated:YES completion:nil];
}

- (IBAction)Camera:(id)sender {
    
    self.ImagePickerController = [[UIImagePickerController alloc]init];
    self.ImagePickerController.delegate = self;
    self.ImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.ImagePickerController animated:YES completion:nil];

}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *imageUrl  = (NSURL *)[info objectForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *representation = [myasset defaultRepresentation];
        CGImageRef resolutionRef = [representation fullResolutionImage];
        
        if (resolutionRef) {
            UIImage *image = [UIImage imageWithCGImage:resolutionRef scale:1.0f orientation:(UIImageOrientation)representation.orientation];
            self.SelectedImage.image =image;
            
            image = [UIImage imageNamed:@"Image.jpg"];
            NSString *stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"New Folder"];
            // New Folder is your folder name
            NSError *error = nil;
            if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
            
            NSString *fileName = [stringPath stringByAppendingFormat:@"/image.jpg"];
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            [data writeToFile:fileName atomically:YES];
             NSFileManager *fileMgr = [NSFileManager defaultManager];
            if ([fileMgr fileExistsAtPath:stringPath]) {
                
                NSLog(@"file exit at path");
            }
            else{
                NSLog(@"file not found");
            }
        }
    };
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"cant get image - %@",[myerror localizedDescription]);
    };
    
    if(imageUrl)
    {
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc]init];
        [assetslibrary assetForURL:imageUrl resultBlock:resultblock failureBlock:failureblock];
    }
   
    
}
// image save karna hoga with uniquename in document directory.
// unique name use database me store for future purpose

- (IBAction)UploadImage:(id)sender {
    
    [self CreateloadingView];
    
    UIImage *img = _SelectedImage.image;
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingString:@"image.png"];
    
    NSData *data = [[NSData alloc] initWithData:UIImagePNGRepresentation(img)];
    [data writeToFile:path atomically:YES];
    
    NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:path];
    
    _uploadRequest = [AWSS3TransferManagerUploadRequest new];
    
    _uploadRequest.bucket = @"s3-ios-test";
    
    _uploadRequest.key = @"sanjeet/image.png";
    
    _uploadRequest.contentType = @"image/png";
    
    _uploadRequest.body = fileUrl;
    
    _uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    
     __weak ViewController *weakSelf = self;
    
    // show the uploadProgress
    
    _uploadRequest.uploadProgress = ^(int64_t bytesSent,int64_t totalBytesSent,int64_t totalBytesExpectedTosend){
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.amountUploaded = totalBytesSent;
            weakSelf.filesize = totalBytesExpectedTosend;
            [weakSelf update];
            
        });
        
    };
    
    
    // upload the file
    
    AWSS3TransferManager *transferManager =[AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:_uploadRequest]continueWithExecutor:[AWSExecutor mainThreadExecutor]block:^id (AWSTask * task) {
        
        if(task.error)
        {
            NSLog(@"\n Error Occured  =    %@", task.error.localizedDescription);
        }
        else
        {
            NSLog(@"Successfully uploaded to server !!!");
            
            NSLog(@"https://s3.amazonaws.com/s3-ios-test/sanjeet/image.png");
        }
        return nil;
    } cancellationToken:nil];

}

- (IBAction)DownloadImage:(id)sender {
    
    
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloaded-myImage.jpg"];
    NSURL *downloadingFileUrl = [NSURL fileURLWithPath:downloadingFilePath];
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    downloadRequest.bucket = @"s3-ios-test";
    
    downloadRequest.key = @"sanjeet/dilip.png";
    
    downloadRequest.downloadingFileURL = downloadingFileUrl;
    
    
    // show the download progress
    
    downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
        });
    };
    
    // Download the file.
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task) {
                                                               if (task.error){
                                                                   if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                       switch (task.error.code) {
                                                                           case AWSS3TransferManagerErrorCancelled:
                                                                           case AWSS3TransferManagerErrorPaused:
                                                                               break;
                                                                               
                                                                           default:
                                                                               NSLog(@"Error: %@", task.error);
                                                                               break;
                                                                       }
                                                                   } else {
                                                                       NSLog(@"Error: %@", task.error);
                                                                   }
                                                               }
                                                               
                                                               if (task.result) {
                                                                   AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
                                                                   NSLog(@"File downloaded successfully.");
                                                                   _SelectedImage.image = [UIImage imageWithContentsOfFile:downloadingFilePath];
                                                               }
                                                               return nil;
                                                           }];
}

-(void)update
{
    _progressLabel.text = [NSString stringWithFormat:@"uploading:%.0f%%",((float)self.amountUploaded/(float)self.filesize)*100];
}

-(void)CreateloadingView
{
    _loadingBg = [[UIView alloc]initWithFrame:self.view.frame];
    [_loadingBg setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.35]];
    
    [self.view addSubview:_loadingBg];
    
    _progressview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    _progressview.center = self.view.center;
    [_progressview setBackgroundColor:[UIColor whiteColor]];
    
    [_loadingBg addSubview:_progressview];
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    _progressLabel.center = self.view.center;
    [_progressLabel setBackgroundColor:[UIColor blueColor]];
    
    [_progressLabel setTextAlignment:NSTextAlignmentCenter];
    
    [_loadingBg addSubview:_progressLabel];
    
}
@end
