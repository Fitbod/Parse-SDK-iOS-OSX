//
//  PFAppleUtils.h
//  Parse
//
//  Created by Alex Reynolds on 9/3/19.
//

#import <Foundation/Foundation.h>
#import <Bolts/BFExecutor.h>
#import <Bolts/BFTask.h>

#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>

NS_ASSUME_NONNULL_BEGIN


@interface PFAppleUtils : NSObject

/*
 @warning You must invoke this in order to use the Facebook functionality in Parse.

 @param launchOptions The launchOptions as passed to [UIApplicationDelegate application:didFinishLaunchingWithOptions:].
 */
+ (void)initializeAppleWithApplicationLaunchOptions:(nullable NSDictionary *)launchOptions;


/**
 *Asynchronously* logs in a user using Facebook with read permissions.

 This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a `PFUser`.

 @param permissions Array of read permissions to use.
 @param block       The block to execute when the log in completes.
 It should have the following signature: `^(PFUser *user, NSError *error)`.
 */
+ (void)logInInBackgroundWithReadPermissions:(nullable NSArray<NSString *> *)permissions
                                       block:(nullable PFUserResultBlock)block;

/**
 *Asynchronously* logs in a user using Facebook with read permissions.

 This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a `PFUser`.

 @param permissions Array of read permissions to use.
 @param block       The block to execute when the log in completes.
 It should have the following signature: `^(PFUser *user, NSError *error)`.
 */
+ (void)createInBackgroundWithReadPermissions:(nullable NSArray<NSString *> *)permissions
                                       block:(nullable PFUserResultBlock)block;
//--------------------------------------
/// @name Linking Users
///--------------------------------------

/**
 *Asynchronously* links Facebook with read permissions to an existing `PFUser`.

 This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the `PFUser`.
 It will also save any unsaved changes that were made to the `user`.

 @param user        User to link to Facebook.
 @param permissions Array of read permissions to use when logging in with Facebook.

 @return The task that will have a `result` set to `@YES` if operation succeeds.
 */
+ (BFTask<NSNumber *> *)linkUserInBackground:(PFUser *)user
                                   withReadPermissions:(nullable NSArray<NSString *> *)permissions;

/**
 *Asynchronously* links Facebook with read permissions to an existing `PFUser`.

 This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the `PFUser`.
 It will also save any unsaved changes that were made to the `user`.

 @param user        User to link to Facebook.
 @param permissions Array of read permissions to use.
 @param block       The block to execute when the linking completes.
 It should have the following signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)linkUserInBackground:(PFUser *)user
         withReadPermissions:(nullable NSArray<NSString *> *)permissions
                       block:(nullable PFBooleanResultBlock)block;

/**
 *Asynchronously* links Facebook with publish permissions to an existing `PFUser`.

 This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the `PFUser`.
 It will also save any unsaved changes that were made to the `user`.

 @param user        User to link to Facebook.
 @param permissions Array of publish permissions to use.

 @return The task that will have a `result` set to `@YES` if operation succeeds.
 */
+ (BFTask<NSNumber *> *)linkUserInBackground:(PFUser *)user
                                withPublishPermissions:(NSArray<NSString *> *)permissions;

/**
 *Asynchronously* links Facebook with publish permissions to an existing `PFUser`.

 This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the `PFUser`.
 It will also save any unsaved changes that were made to the `user`.

 @param user        User to link to Facebook.
 @param permissions Array of publish permissions to use.
 @param block       The block to execute when the linking completes.
 It should have the following signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)linkUserInBackground:(PFUser *)user
      withPublishPermissions:(NSArray<NSString *> *)permissions
                       block:(nullable PFBooleanResultBlock)block;

///--------------------------------------
/// @name Unlinking Users
///--------------------------------------

/**
 Unlinks the `PFUser` from a Facebook account *asynchronously*.

 @param user User to unlink from Facebook.
 @return The task, that encapsulates the work being done.
 */
+ (BFTask<NSNumber *> *)unlinkUserInBackground:(PFUser *)user;

/**
 Unlinks the `PFUser` from a Facebook account *asynchronously*.

 @param user User to unlink from Facebook.
 @param block The block to execute.
 It should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)unlinkUserInBackground:(PFUser *)user block:(nullable PFBooleanResultBlock)block;


///--------------------------------------
/// @name Getting Linked State
///--------------------------------------

/**
 Whether the user has their account linked to Facebook.

 @param user User to check for a facebook link. The user must be logged in on this device.

 @return `YES` if the user has their account linked to Facebook, otherwise `NO`.
 */
+ (BOOL)isLinkedWithUser:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
