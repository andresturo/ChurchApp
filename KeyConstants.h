//
//  MUConstants.h
//  MatchedUp
//
//  Created by Daniel Cardona on 9/29/14.
//  Copyright (c) 2014 Daniel Cardona. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyConstants : NSObject

#pragma mark - User profile
extern NSString* const kMUUserTagLineKey;

extern NSString *const kUserProfileKey;
extern NSString *const kUserProfileNameKey;
extern NSString* const kUserProfileFirstNameKey;
extern NSString* const kUserProfileLocationKey;
extern NSString* const kUserProfileGenderKey;
extern NSString* const kUserProfileBirthdayKey;
extern NSString* const kUserProfileInterestedInKey;
extern NSString* const kUserProfilePictureURL;
extern NSString* const kUserProfileRelashionshipStatusKey;
extern NSString* const kUserProfileAgeKey;

#pragma mark - Photo class
extern NSString* const kPhotoClassKey;
extern NSString* const kPhotoUserKey;
extern NSString* const kPhotoPictureKey;

#pragma mark - Activiy Class 

extern NSString* const kActivityClassKey;
extern NSString* const kActivityTypeKey;
extern NSString* const kActivityToUserKey;
extern NSString* const kActivityFromUserKey;
extern NSString* const kActivityPhotoKey;
extern NSString* const kActivityTypeLikeKey;
extern NSString* const kActivityTypeDislikeKey;


@end
