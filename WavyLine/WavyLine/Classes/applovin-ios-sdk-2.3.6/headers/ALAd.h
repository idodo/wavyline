//
//  AppLovinAd.h
//  sdk
//
//  Created by Basil on 2/27/12.
//  Copyright (c) 2013, AppLovin Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAdSize.h"
#import "ALAdType.h"

/**
 * This class represents an ad that has been served from AppLovin server and
 * should be displayed to the user.
 *
 * @author Basil Shikin, Matt Szaro
 * @version 1.3
 */
@interface ALAd : NSObject <NSCopying>

@property (strong, nonatomic) ALAdSize * size;
@property (strong, nonatomic) ALAdType * type;
@property (strong, nonatomic) NSString * videoUrl;
@property (strong, nonatomic) NSArray  * destinationUrls;

/* Represents a unique ID for the current ad. Please include this if
 * you report a broken/bad ad to AppLovin Support. */
@property (strong, nonatomic) NSNumber * adIdNumber;

@property (strong, readonly, getter=createEmptyString) NSString * html __deprecated;

@end
