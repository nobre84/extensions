//
//  PhotoEditingViewController.m
//  MediaEffects
//
//  Created by Rafael Nobre on 5/31/15.
//  Copyright (c) 2015 Rafael Nobre. All rights reserved.
//

#import "PhotoEditingViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "TabCollectionViewCell.h"
#import "GPUImage.h"
@import MobileCoreServices;
@import ImageIO;

@interface PhotoEditingViewController () <PHContentEditingController, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong) PHContentEditingInput *input;

@property (strong, nonatomic) NSArray *filters;

@property (strong, nonatomic) NSArray *filterClasses;

@property (weak, nonatomic) IBOutlet UIImageView *ivPreview;

@property (strong, nonatomic) GPUImageFilter *selectedFilter;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation PhotoEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.filters = @[@"Blur",
                     @"Sharpen",
                     @"Sepia",
                     @"Cartoon",
                     @"Pixelate",
                     @"Sketch",
                     @"Grayscale",
                     @"Swirl",
                     @"Vignette"];
    
    self.filterClasses = @[[GPUImageiOSBlurFilter class],
                           [GPUImageSharpenFilter class],
                           [GPUImageSepiaFilter class],
                           [GPUImageToonFilter class],
                           [GPUImagePixellateFilter class],
                           [GPUImageSketchFilter class],
                           [GPUImageGrayscaleFilter class],
                           [GPUImageSwirlFilter class],
                           [GPUImageVignetteFilter class]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.ivPreview.image = self.input.displaySizeImage;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Warning...");
}

#pragma mark - UICollectionView

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TabCollectionViewCell *cell = (TabCollectionViewCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"filterCell" forIndexPath:indexPath];
    cell.lbTitle.text = self.filters[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFilter = [self.filterClasses[indexPath.row] new];
    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *processedPreview = [self.selectedFilter imageByFilteringImage:self.input.displaySizeImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ivPreview.image = processedPreview;
            [self.activityIndicator stopAnimating];
        });
    });
}

#pragma mark - PHContentEditingController

- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData {
    // Inspect the adjustmentData to determine whether your extension can work with past edits.
    // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
    return NO;
}

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage {
    // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
    // If you returned YES from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
    // If you returned NO, the contentEditingInput has past edits "baked in".
    self.input = contentEditingInput;
}

- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler {
    // Update UI to reflect that editing has finished and output is being rendered.
    self.view.userInteractionEnabled = NO;
    [self.activityIndicator startAnimating];
    
    // Render and provide output on a background queue.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Create editing output from the editing input.
        PHContentEditingOutput *output = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.input];
        
        // Provide new adjustments and render output to given location.
        output.adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:[[NSBundle mainBundle] bundleIdentifier] formatVersion:@"1.0" data:[[self.selectedFilter description] dataUsingEncoding:NSUTF8StringEncoding]];
//        UIImage *fullSizeImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.input.fullSizeImageURL]];
        
        GPUImagePicture *imageInput = [[GPUImagePicture alloc] initWithURL:self.input.fullSizeImageURL];
        
        [imageInput addTarget:self.selectedFilter];
        
        [self.selectedFilter useNextFrameForImageCapture];
        
        [imageInput processImage];
        
        CGImageRef image = [self.selectedFilter newCGImageFromCurrentlyProcessedOutput];
        
        CGImageWriteToURL(image, output.renderedContentURL);
        
//        UIImage *fullProcessedImage = [self.selectedFilter imageByFilteringImage:fullSizeImage];
//        fullSizeImage = nil;
//        NSData *renderedJPEGData = UIImageJPEGRepresentation(fullProcessedImage, 0.9);
//        fullProcessedImage = nil;
//        [renderedJPEGData writeToURL:output.renderedContentURL atomically:YES];
//        renderedJPEGData = nil;
        
        // Call completion handler to commit edit to Photos.
        completionHandler(output);
        
        // Clean up temporary files, etc.
        self.selectedFilter = nil;
    });
}

BOOL CGImageWriteToURL(CGImageRef image, NSURL *url) {
    CFURLRef cfurl = (__bridge CFURLRef)url;
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(cfurl, kUTTypeJPEG, 1, NULL);
    @try {
        if (!destination) {
            NSLog(@"Failed to create destination for %@", url);
            return NO;
        }
        CGImageDestinationAddImage(destination, image, NULL);
        
        if (!CGImageDestinationFinalize(destination)) {
            NSLog(@"Failed to write image to %@", url);
            return NO;
        }

    }
    @catch (NSException *exception) {
    }
    @finally {
        CFRelease(destination);
    }
    
    return YES;
}

- (BOOL)shouldShowCancelConfirmation {
    // Returns whether a confirmation to discard changes should be shown to the user on cancel.
    // (Typically, you should return YES if there are any unsaved changes.)
    return NO;
}

- (void)cancelContentEditing {
    // Clean up temporary files, etc.
    // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
}

@end
