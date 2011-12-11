//
//  CIDoorwaySegue.m
//  Doorway Segue
//
//  Copyright (c) 2011 Core Intellect, LLC.
//  Licensed under the MIT License (see LICENSE for more details)
//
//  The Doorway Segue is based on MFDoorwayTransition by Ken Matsui and portions
//  of this code are Copyright (c) 2011 Ken Matsui. More information on
//  MFDoorwayTransition may be found at https://github.com/mkftr/DoorwayTransition
//

#import "CIAppDelegate.h"
#import "CIDoorwaySegue.h"
#import <QuartzCore/QuartzCore.h>

CGFloat degreeToRadian(CGFloat degree)
{
  return degree * M_PI / 180.0f;
}

@interface CIDoorwaySegue ()

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) CALayer *doorLayerLeft;
@property (nonatomic, retain) CALayer *doorLayerRight;
@property (nonatomic, retain) CALayer *nextViewLayer;

- (CAAnimation *)openDoorAnimationWithRotationDegree:(CGFloat)degree;
- (CAAnimation *)zoomInAnimation;

@end

@implementation CIDoorwaySegue

@synthesize window;
@synthesize doorLayerLeft;
@synthesize doorLayerRight;
@synthesize nextViewLayer;

- (void)perform
{
  self.window = [[[UIApplication sharedApplication] delegate] window];
  CGSize viewSize      = [(UIView *)[self.window.subviews objectAtIndex:0] frame].size;
  CGPoint viewOrigin   = [(UIView *)[self.window.subviews objectAtIndex:0] frame].origin;
  CGRect leftDoorRect  = CGRectMake(viewOrigin.x, viewOrigin.y, viewSize.width / 2.0f, viewSize.height);
  CGRect rightDoorRect = CGRectMake(viewSize.width / 2.0f, viewOrigin.y, viewSize.width / 2.0f, viewSize.height);

  self.doorLayerLeft = [CALayer layer];
  self.doorLayerLeft.anchorPoint = CGPointMake(0.0f, 0.5f);
  self.doorLayerLeft.frame  = leftDoorRect;
  CATransform3D leftTransform = self.doorLayerLeft.transform;
  leftTransform.m34 = 1.0f / -420.0f;
  self.doorLayerLeft.transform = leftTransform;
  self.doorLayerLeft.shadowOffset = CGSizeMake(5.0f, 5.0f);
  
  self.doorLayerRight = [CALayer layer];
  self.doorLayerRight.anchorPoint = CGPointMake(1.0f, 0.5f);
  self.doorLayerRight.frame = rightDoorRect;
  CATransform3D rightTransform = self.doorLayerRight.transform;
  rightTransform.m34 = 1.0f / -420.0f;
  self.doorLayerRight.transform = rightTransform;
  self.doorLayerRight.shadowOffset = CGSizeMake(5.0f, 5.0f);
  
  self.nextViewLayer = [CALayer layer];
  self.nextViewLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
  self.nextViewLayer.frame = CGRectMake(viewOrigin.x, viewOrigin.y, viewSize.width, viewSize.height);
  CATransform3D nextViewTransform = self.nextViewLayer.transform;
  nextViewTransform.m34 = 1.0f / -420.0f;
  self.nextViewLayer.transform = nextViewTransform;
  
  // Left door image
  self.doorLayerLeft.contents = (id)[CIDoorwaySegue clipImageFromLayer:[[self.sourceViewController view] layer] size:leftDoorRect.size offsetX:0.0f];
  
  // Right door image
  self.doorLayerRight.contents = (id)[CIDoorwaySegue clipImageFromLayer:[[self.sourceViewController view] layer] size:rightDoorRect.size offsetX:-leftDoorRect.size.width];
  
  // Next view image
  self.nextViewLayer.contents = (id)[CIDoorwaySegue clipImageFromLayer:[[self.destinationViewController view] layer] size:viewSize offsetX:0.0f];

  [self.window.layer addSublayer:self.doorLayerLeft];
  [self.window.layer addSublayer:self.doorLayerRight];
  [self.window.layer addSublayer:self.nextViewLayer];

  CAAnimation *leftDoorAnimation = [self openDoorAnimationWithRotationDegree:90.0f];
  leftDoorAnimation.delegate = self;
  [self.doorLayerLeft addAnimation:leftDoorAnimation forKey:@"doorAnimationStarted"];
  
  CAAnimation *rightDoorAnimation = [self openDoorAnimationWithRotationDegree:-90.0f];
  rightDoorAnimation.delegate = self;
  [self.doorLayerRight addAnimation:rightDoorAnimation forKey:@"doorAnimationStarted"];
  
  CAAnimation *nextViewAnimation = [self zoomInAnimation];
  nextViewAnimation.delegate = self;
  [self.nextViewLayer addAnimation:nextViewAnimation forKey:@"NextViewAnimationStarted"];

  [[self.sourceViewController view] removeFromSuperview];
}

#pragma mark - Core Animation Delegates

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)isFinished
{
  if (isFinished)
  {
    if ([self.doorLayerLeft animationForKey:@"doorAnimationStarted"] == animation ||
       [self.doorLayerRight animationForKey:@"doorAnimationStarted"] == animation)
    {
      [self.doorLayerLeft removeFromSuperlayer];
      [self.doorLayerRight removeFromSuperlayer];
    }
    else 
    {
      [self.window setRootViewController:self.destinationViewController];
    }
  }
}

#pragma makr - Image Utilities

+ (CGImageRef)clipImageFromLayer:(CALayer *)layer size:(CGSize)size offsetX:(CGFloat)offsetX
{
  UIGraphicsBeginImageContext(size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, offsetX, 0.0f);
  [layer renderInContext:context];
  UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return snapshot.CGImage;
}

#pragma mark - Animations

- (CAAnimation *)zoomInAnimation
{
  CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
  
  CABasicAnimation *zoomInAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
  zoomInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  zoomInAnimation.fromValue = [NSNumber numberWithFloat:-1000.0f];
  zoomInAnimation.toValue = [NSNumber numberWithFloat:0.0f];
  
  CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  fadeInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
  fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0f];
  
  animationGroup.animations = [NSArray arrayWithObjects:zoomInAnimation, fadeInAnimation, nil];
  animationGroup.duration = 1.5f;
  
  return animationGroup;
}

- (CAAnimation *)openDoorAnimationWithRotationDegree:(CGFloat)degree
{
  CAAnimationGroup *animationGroup = [CAAnimationGroup animation];

  CABasicAnimation *openAnimimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
  openAnimimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  openAnimimation.fromValue = [NSNumber numberWithFloat:degreeToRadian(0.0f)];
  openAnimimation.toValue = [NSNumber numberWithFloat:degreeToRadian(degree)];
  
  CABasicAnimation *zoomInAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
  zoomInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  zoomInAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
  zoomInAnimation.toValue = [NSNumber numberWithFloat:300.0f];
  
  animationGroup.animations = [NSArray arrayWithObjects:openAnimimation, zoomInAnimation, nil];
  animationGroup.duration = 1.5f;
  
  return animationGroup;
}

@end
