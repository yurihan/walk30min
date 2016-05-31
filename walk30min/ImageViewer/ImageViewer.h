//
// ImageViewer.h
// Version 2.0
//
// Copyright (c) 2013 Michael Henry Pantaleon (http://www.iamkel.net). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <UIKit/UIKit.h>

typedef void (^ImageViewerOpeningBlock)(void);
typedef void (^ImageViewerClosingBlock)(void);


@class ImageViewer;
@protocol ImageViewerDatasource <NSObject>
@required
- (NSInteger) numberImagesForImageViewer:(ImageViewer*) imageViewer;
- (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(ImageViewer*) imageViewer;
- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(ImageViewer*) imageViewer;
@end

@interface ImageViewer : UIViewController
@property (weak, readonly, nonatomic) UIViewController *rootViewController;
@property (nonatomic,strong) NSURL * imageURL;
@property (nonatomic,strong) UIImageView * senderView;
@property (nonatomic,weak) ImageViewerOpeningBlock openingBlock;
@property (nonatomic,weak) ImageViewerClosingBlock closingBlock;
@property (nonatomic,weak) id<ImageViewerDatasource> imageDatasource;
@property (nonatomic,assign) NSInteger initialIndex;


- (void)presentFromRootViewController;
- (void)presentFromViewController:(UIViewController *)controller;
@end

#pragma mark - UIImageView Category

@interface UIImageView(ImageViewer)
- (void) setupImageViewer;
- (void) setupImageViewerWithCompletionOnOpen:(ImageViewerOpeningBlock)open onClose:(ImageViewerClosingBlock)close;
- (void) setupImageViewerWithImageURL:(NSURL*)url;
- (void) setupImageViewerWithImageURL:(NSURL *)url onOpen:(ImageViewerOpeningBlock)open onClose:(ImageViewerClosingBlock)close;
- (void) setupImageViewerWithDatasource:(id<ImageViewerDatasource>)imageDatasource onOpen:(ImageViewerOpeningBlock)open onClose:(ImageViewerClosingBlock)close;
- (void) setupImageViewerWithDatasource:(id<ImageViewerDatasource>)imageDatasource initialIndex:(NSInteger)initialIndex onOpen:(ImageViewerOpeningBlock)open onClose:(ImageViewerClosingBlock)close;
- (void)removeImageViewer;
@end

