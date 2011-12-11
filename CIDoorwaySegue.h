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

#import <UIKit/UIKit.h>

CGFloat degreeToRadian(CGFloat degree);

@interface CIDoorwaySegue : UIStoryboardSegue

+ (CGImageRef)clipImageFromLayer:(CALayer *)layer size:(CGSize)size offsetX:(CGFloat)offsetX;

@end
