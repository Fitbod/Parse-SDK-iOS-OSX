//
//  PFAppleAuthentication.h
//  Adjust
//
//  Created by Alex Reynolds on 9/3/19.
//

#import <Foundation/Foundation.h>
#import "PFUserAuthenticationDelegate.h"

#import <Bolts/BFTask.h>
#import <AuthenticationServices/AuthenticationServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface PFAppleAuthenticationResult : NSObject

@property (nonatomic, nonnull, strong) NSString *username;
@property (nonatomic, nonnull, strong) NSString *email;
@property (nonatomic) BOOL isCancelled;
@property (nonatomic, nonnull, strong) NSData *token;
@property (nonatomic, nonnull, strong) NSData *code;
@property (nonatomic, nonnull, strong) NSPersonNameComponents *name;

@end


extern NSString *const PFAppleUserAuthenticationType;

typedef void (^PFAppleLoginHandler)(PFAppleAuthenticationResult *result, NSError* _Nullable error);


@interface PFAppleAuthenticationProvider : NSObject <PFUserAuthenticationDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>
@property (nonatomic, strong, readonly) PFAppleLoginHandler loginHandler;
@property (nonatomic, strong, readonly) PFAppleAuthenticationResult *result;



///--------------------------------------
/// @name Init
///--------------------------------------

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithApplication:(UIApplication *)application
                      launchOptions:(nullable NSDictionary *)launchOptions NS_DESIGNATED_INITIALIZER;
+ (instancetype)providerWithApplication:(UIApplication *)application
                          launchOptions:(nullable NSDictionary *)launchOptions;;

+ (NSDictionary *)userAuthenticationDataWithPFAppleAuthenticationResult:(PFAppleAuthenticationResult *)result;
///--------------------------------------
/// @name Authenticate
///--------------------------------------

- (BFTask<NSDictionary<NSString *, NSString *>*> *)authenticateAsyncWithReadPermissions:(nullable NSArray<NSString *> *)readPermissions
                                                                     publishPermissions:(nullable NSArray<NSString *> *)publishPermissions isLogIn:(BOOL)isLogIn;
- (BFTask<NSDictionary<NSString *, NSString *>*> *)authenticateAsyncWithReadPermissions:(nullable NSArray<NSString *> *)readPermissions
                                                                     publishPermissions:(nullable NSArray<NSString *> *)publishPermissions
                                                                     fromViewComtroller:(UIViewController *)viewController isLogIn:(BOOL)isLogIn;
@end

NS_ASSUME_NONNULL_END
