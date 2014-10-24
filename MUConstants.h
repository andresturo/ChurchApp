//
//  MUConstants.h
//  MatchedUp
//
//  Created by Daniel Cardona on 9/29/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUConstants : NSObject

#pragma mark - User profile
extern NSString* const kMUUserTagLineKey;

extern NSString *const kMUUserProfileKey;
extern NSString *const kMUUserProfileNameKey;
extern NSString* const kMUUserProfileFirstNameKey;
extern NSString* const kMUUserProfileLocationKey;
extern NSString* const kMUUserProfileGenderKey;
extern NSString* const kMUUserProfileBirthdayKey;
extern NSString* const kMUUserProfileInterestedInKey;
extern NSString* const kMUUserProfilePictureURL;
extern NSString* const kMUUserProfileRelashionshipStatusKey;
extern NSString* const kMUUserProfileAgeKey;

#pragma mark - Photo class
extern NSString* const kMUPhotoClassKey;
extern NSString* const kMUPhotoUserKey;
extern NSString* const kMUPhotoPictureKey;

#pragma mark - Activiy Class 

extern NSString* const kMUActivityClassKey;
extern NSString* const kMUActivityTypeKey;
extern NSString* const kMUActivityToUserKey;
extern NSString* const kMUActivityFromUserKey;
extern NSString* const kMUActivityPhotoKey;
extern NSString* const kMUActivityTypeLikeKey;
extern NSString* const kMUActivityTypeDislikeKey;


@end
