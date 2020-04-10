//
//  PFAppleUtils.m
//  Parse
//
//  Created by Alex Reynolds on 9/3/19.
//

#import "PFAppleUtils.h"
#import "PFAppleAuthenticationProvider.h"
#import <AuthenticationServices/AuthenticationServices.h>
@implementation PFAppleUtils

///--------------------------------------
#pragma mark - Authentication Provider
///--------------------------------------

static PFAppleAuthenticationProvider *authenticationProvider_;

+ (void)_assertAppleInitialized {
    if (!authenticationProvider_) {
        [NSException raise:NSInternalInconsistencyException format:@"You must initialize PFAppleUtils with a call to +initializeAppleWithApplicationLaunchOptions"];
    }
}

+ (PFAppleAuthenticationProvider *)_authenticationProvider {
    return authenticationProvider_;
}

+ (void)_setAuthenticationProvider:(PFAppleAuthenticationProvider *)provider {
    authenticationProvider_ = provider;
}


///--------------------------------------
#pragma mark - Interacting With Facebook
///--------------------------------------

+ (void)initializeAppleWithApplicationLaunchOptions:(NSDictionary *)launchOptions {
    if (!authenticationProvider_) {
        Class providerClass = [PFAppleAuthenticationProvider class];

        PFAppleAuthenticationProvider *provider = [providerClass providerWithApplication:[UIApplication sharedApplication]
                                                                              launchOptions:launchOptions];
        [PFUser registerAuthenticationDelegate:provider forAuthType:PFAppleUserAuthenticationType];
        
        [self _setAuthenticationProvider:provider];
    }
}




+ (BFTask<PFUser *> *)logInInBackgroundWithReadPermissions:(nullable NSArray<NSString *> *)permissions {
    return [self _logInAsyncWithReadPermissions:permissions publishPermissions:nil isLogIn:true];
}

+ (BFTask<PFUser *> *)createInBackgroundWithReadPermissions:(nullable NSArray<NSString *> *)permissions {
    return [self _logInAsyncWithReadPermissions:permissions publishPermissions:nil isLogIn:false];
}

+ (void)logInInBackgroundWithReadPermissions:(nullable NSArray<NSString *> *)permissions
                                       block:(nullable PFUserResultBlock)block {
    [[self logInInBackgroundWithReadPermissions:permissions] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<PFUser *> * _Nonnull task) {
        if (block) {
            PFAppleAuthenticationProvider *authenticationProvider = [self _authenticationProvider];
            PFUser *user = (PFUser*)task.result;
            if (authenticationProvider.result.email != nil) {
                user.email = authenticationProvider.result.email;
            }
            if (authenticationProvider.result.name.givenName != nil) {
                user[@"firstName"] = authenticationProvider.result.name.givenName;
            }
            if (authenticationProvider.result.name.familyName != nil) {
                user[@"lastName"] = authenticationProvider.result.name.familyName;
            }
            block(task.result, task.error);
        }
        return nil;

    }];
    
    
}

+ (void)createInBackgroundWithReadPermissions:(nullable NSArray<NSString *> *)permissions
                                       block:(nullable PFUserResultBlock)block {
    [[self createInBackgroundWithReadPermissions:permissions] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<PFUser *> * _Nonnull task) {
        if (block) {
            PFAppleAuthenticationProvider *authenticationProvider = [self _authenticationProvider];
            PFUser *user = (PFUser*)task.result;
            if (authenticationProvider.result.email != nil) {
                user.email = authenticationProvider.result.email;
            }
            if (authenticationProvider.result.name.givenName != nil) {
                user[@"firstName"] = authenticationProvider.result.name.givenName;
            }
            if (authenticationProvider.result.name.familyName != nil) {
                user[@"lastName"] = authenticationProvider.result.name.familyName;
            }
            block(task.result, task.error);
        }
        return nil;

    }];
    
    
}

+ (BFTask<PFUser *> *)_logInAsyncWithReadPermissions:(NSArray<NSString *> *)readPermissions
                                  publishPermissions:(NSArray<NSString *> *)publishPermissions isLogIn:(BOOL)isLogIn{
    [self _assertAppleInitialized];

    PFAppleAuthenticationProvider *provider = [self _authenticationProvider];
    return [[provider authenticateAsyncWithReadPermissions:readPermissions
                                        publishPermissions:publishPermissions isLogIn:isLogIn] continueWithSuccessBlock:^id(BFTask *task) {
        NSDictionary *authData = [PFAppleAuthenticationProvider userAuthenticationDataWithPFAppleAuthenticationResult:task.result];
        BFTask<PFUser *> *returnTask = [PFUser logInWithAuthTypeInBackground:PFAppleUserAuthenticationType authData:authData];
        
        return returnTask;
    }];
}




/*
if #available(iOS 13.0, *) {
    if (self.type == TYPE.create) {

        let requestNewUSer = ASAuthorizationAppleIDProvider().createRequest()
        requestNewUSer.requestedScopes = [.email, .fullName]
        var requests = [requestNewUSer]
        let controller = ASAuthorizationController(authorizationRequests: requests)
        
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    } else if (self.type == TYPE.login) {
        var requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        let controller = ASAuthorizationController(authorizationRequests: requests)
        
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
} else {
    // Fallback on earlier versions
}
 
*/

///--------------------------------------
#pragma mark - Linking Users
///--------------------------------------

+ (BFTask<NSNumber *> *)linkUserInBackground:(PFUser *)user
                         withReadPermissions:(nullable NSArray<NSString *> *)permissions {
    return [self _linkUserAsync:user withReadPermissions:permissions publishPermissions:nil];
}

+ (void)linkUserInBackground:(PFUser *)user
         withReadPermissions:(nullable NSArray<NSString *> *)permissions
                       block:(nullable PFBooleanResultBlock)block {
    
    [[self linkUserInBackground:user withReadPermissions:permissions] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<PFUser *> * _Nonnull task) {
        if (block) {
            block(task.result, task.error);
        }
        return nil;

    }];
}

+ (BFTask<NSNumber *> *)linkUserInBackground:(PFUser *)user
                      withPublishPermissions:(NSArray<NSString *> *)permissions {
    return [self _linkUserAsync:user withReadPermissions:nil publishPermissions:permissions];
}

+ (void)linkUserInBackground:(PFUser *)user
      withPublishPermissions:(NSArray<NSString *> *)permissions
                       block:(nullable PFBooleanResultBlock)block {
    [[self linkUserInBackground:user withPublishPermissions:permissions] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<PFUser *> * _Nonnull task) {
        if (block) {
            block(task.result, task.error);
        }
        return nil;

    }];
}

+ (BFTask *)_linkUserAsync:(PFUser *)user
       withReadPermissions:(nullable NSArray<NSString *> *)readPermissions
        publishPermissions:(nullable NSArray<NSString *> *)publishPermissions {
    [self _assertAppleInitialized];

    PFAppleAuthenticationProvider *authenticationProvider = [self _authenticationProvider];
    return [[authenticationProvider authenticateAsyncWithReadPermissions:readPermissions
                                                      publishPermissions:publishPermissions isLogIn:false] continueWithSuccessBlock:^id(BFTask *task) {
        return [user linkWithAuthTypeInBackground:PFAppleUserAuthenticationType authData:task.result];
    }];
}


///--------------------------------------
#pragma mark - Getting Linked State
///--------------------------------------

+ (BOOL)isLinkedWithUser:(PFUser *)user {
    return [user isLinkedWithAuthType:PFAppleUserAuthenticationType];
}

///--------------------------------------
#pragma mark - Unlinking
///--------------------------------------

+ (BFTask<NSNumber *> *)unlinkUserInBackground:(PFUser *)user {
    [self _assertAppleInitialized];
    return [user unlinkWithAuthTypeInBackground:PFAppleUserAuthenticationType];
}

+ (void)unlinkUserInBackground:(PFUser *)user block:(nullable PFBooleanResultBlock)block {
    [[self unlinkUserInBackground:user] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<PFUser *> * _Nonnull task) {
        if (block) {
            block(task.completed, task.error);
        }
        return nil;
    }];
}
@end
