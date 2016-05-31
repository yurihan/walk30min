//
//  BlurView.m
//  walk30min
//
//  Created by YuriHan on 13. 10. 4..
//  Copyright (c) 2013년 YuriHan. All rights reserved.
//

#import "BlurView.h"
#import <QuartzCore/QuartzCore.h>

@interface BlurView ()

@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation BlurView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // If we don't clip to bounds the toolbar draws a thin shadow on top
    [self setClipsToBounds:YES];
	self.backgroundColor = [UIColor clearColor];
    
    if (![self toolbar]) {
        [self setToolbar:[[UIToolbar alloc] initWithFrame:[self bounds]]];
        [self.layer insertSublayer:[self.toolbar layer] atIndex:0];
		self.layer.cornerRadius = 20;
		//self.toolbar.barTintColor = [UIColor colorWithRed:59.0/255 green:153.0/255 blue:204.0/255 alpha:1.0];
		self.toolbar.barTintColor = [UIColor lightGrayColor];
		
    }
}

- (void) setBlurTintColor:(UIColor *)blurTintColor {
    [self.toolbar setBarTintColor:blurTintColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.toolbar setFrame:[self bounds]];
}

@end
