//
//  PFAppleAuthentication.m
//  Adjust
//
//  Created by Alex Reynolds on 9/3/19.
//

#import "PFAppleAuthenticationProvider.h"
#import <Bolts/BFTaskCompletionSource.h>

NSString *const PFAppleUserAuthenticationType = @"apple";



@implementation PFAppleAuthenticationResult



@end

@implementation PFAppleAuthenticationProvider 


///--------------------------------------
#pragma mark - Init
///--------------------------------------

- (instancetype)initWithApplication:(UIApplication *)application
                      launchOptions:(nullable NSDictionary *)launchOptions {
    self = [super init];
    if (!self) return self;
    
    
    return self;
}

+ (instancetype)providerWithApplication:(UIApplication *)application
                          launchOptions:(nullable NSDictionary *)launchOptions {
    return [[self alloc] initWithApplication:application launchOptions:launchOptions];
}

///--------------------------------------
#pragma mark - Authenticate
///--------------------------------------

- (BFTask<NSDictionary<NSString *, NSString *>*> *)authenticateAsyncWithReadPermissions:(nullable NSArray<NSString *> *)readPermissions
                                                                     publishPermissions:(nullable NSArray<NSString *> *)publishPermissions isLogIn:(BOOL)isLogIn {
    return [self authenticateAsyncWithReadPermissions:readPermissions
                                   publishPermissions:publishPermissions
                                   fromViewComtroller:[PFAppleAuthenticationProvider applicationTopViewController] isLogIn:isLogIn];
}

- (BFTask<NSDictionary<NSString *, NSString *>*> *)authenticateAsyncWithReadPermissions:(nullable NSArray<NSString *> *)readPermissions
                                                                     publishPermissions:(nullable NSArray<NSString *> *)publishPermissions
                                                                     fromViewComtroller:(UIViewController *)viewController isLogIn:(BOOL)isLogIn {
    
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    _loginHandler = ^(PFAppleAuthenticationResult *result, NSError* _Nullable error) {
        if (result.isCancelled) {
            [taskCompletionSource cancel];
        } else if (error != nil) {
            taskCompletionSource.error = error;
        } else {
            self->_result = result;
            taskCompletionSource.result = result;
        }
    };
    
    if (@available(iOS 13.0, *)) {
        if (isLogIn) {
            // Prepare requests for both Apple ID and password providers.
            ASAuthorizationAppleIDRequest *requestNewUSer = [[[ASAuthorizationAppleIDProvider alloc] init] createRequest];
            requestNewUSer.requestedScopes = @[ASAuthorizationScopeEmail, ASAuthorizationScopeFullName];
            ASAuthorizationPasswordRequest *requestExisting = [[[ASAuthorizationPasswordProvider alloc] init] createRequest];
            NSArray *requests = @[requestNewUSer];
            
            // Create an authorization controller with the given requests.
            ASAuthorizationController *controller =  [[ASAuthorizationController alloc]initWithAuthorizationRequests:requests];
            controller.delegate = self;
            controller.presentationContextProvider = self;
            [controller performRequests];
        } else {
            ASAuthorizationAppleIDRequest *requestNewUSer = [[[ASAuthorizationAppleIDProvider alloc] init] createRequest];
            requestNewUSer.requestedScopes = @[ASAuthorizationScopeEmail, ASAuthorizationScopeFullName];
            NSArray *requests = @[requestNewUSer];
            ASAuthorizationController *controller = [[ASAuthorizationController alloc]initWithAuthorizationRequests:requests];

            controller.delegate = self;
            controller.presentationContextProvider = self;
            [controller performRequests];
            
        }

    } else {
        PFAppleAuthenticationResult *result = [[PFAppleAuthenticationResult alloc] init];
        self.loginHandler(result, nil);
        // Fallback on earlier versions
    }
    
//
//    if (publishPermissions) {
//        [self.loginManager logInWithPublishPermissions:publishPermissions
//                                    fromViewController:viewController
//                                               handler:resultHandler];
//    } else {
//        [self.loginManager logInWithReadPermissions:readPermissions
//                                 fromViewController:viewController
//                                            handler:resultHandler];
//    }
    return taskCompletionSource.task;
    
    
}

+ (NSDictionary *)userAuthenticationDataWithPFAppleAuthenticationResult:(PFAppleAuthenticationResult *)result{
    return @{ @"id" : result.username,
              @"token" : [[NSString alloc] initWithData:result.token encoding:NSUTF8StringEncoding]
    };
}


+ (UIViewController *)applicationTopViewController {
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }
    return viewController;
}

- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    UIViewController *top = [PFAppleAuthenticationProvider applicationTopViewController];
    return top.view.window;
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error  API_AVAILABLE(ios(13.0)){
    PFAppleAuthenticationResult *result = [[PFAppleAuthenticationResult alloc] init];

    self.loginHandler(result, error);
    NSLog(@"failed sign in with apple %@", error.localizedDescription);
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization  API_AVAILABLE(ios(13.0)){
    NSLog(@"Success sign in with apple");
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        NSString *user = [(ASAuthorizationAppleIDCredential *)authorization.credential user];
        NSData *token = [(ASAuthorizationAppleIDCredential *)authorization.credential identityToken];
        NSData *code = [(ASAuthorizationAppleIDCredential *)authorization.credential authorizationCode];
        ASUserDetectionStatus *status = [(ASAuthorizationAppleIDCredential *)authorization.credential realUserStatus];
        NSString *email = [(ASAuthorizationAppleIDCredential *)authorization.credential email];
        NSPersonNameComponents *name = [(ASAuthorizationAppleIDCredential *)authorization.credential fullName];
        PFAppleAuthenticationResult *result = [[PFAppleAuthenticationResult alloc] init];
        result.isCancelled = false;
        result.username = user;
        result.token = token;
        result.code = code;
        result.email = email;
        result.name = name;

        self.loginHandler(result, nil);


    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        PFAppleAuthenticationResult *result = [[PFAppleAuthenticationResult alloc] init];
        NSString *user = [(ASPasswordCredential *)authorization.credential user];
        result.isCancelled = false;
        result.username = user;

        self.loginHandler(result, nil);

    } else {
        PFAppleAuthenticationResult *result = [[PFAppleAuthenticationResult alloc] init];
        self.loginHandler(result, [NSError errorWithDomain:@"error" code:-1 userInfo:nil]);
    }
}
/*
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let creds as ASAuthorizationAppleIDCredential :
            let userId = creds.user
            let token = creds.identityToken
            let code = creds.authorizationCode
            let status = creds.realUserStatus
            //creds.email
            //creds.fullName
        case let creds as ASPasswordCredential :
            let userId = creds.user
            
        default:
            break
        }
    }
}
 
 */


///--------------------------------------
#pragma mark - PFUserAuthenticationDelegate
///--------------------------------------

- (BOOL)restoreAuthenticationWithAuthData:(nullable NSDictionary<NSString *, NSString *> *)authData {
    NSLog(@"restore %@", authData);
    NSString *userId = authData[@"id"];
    if (userId == nil) {
        return false;
    }
    if (@available(iOS 13.0, *)) {
        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
        __block NSString *errorMsg = @"";
        [appleIDProvider getCredentialStateForUserID:userId completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
            switch (credentialState) {
                case ASAuthorizationAppleIDProviderCredentialRevoked:
                    errorMsg = @"revoked";
                    break;
                case ASAuthorizationAppleIDProviderCredentialAuthorized:
                    errorMsg = @"completed well";
                    break;
                case ASAuthorizationAppleIDProviderCredentialNotFound:
                    errorMsg = @"credential not found";
                    break;
                case ASAuthorizationAppleIDProviderCredentialTransferred:
                    errorMsg = @"credential transferred";

                    break;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"SignInWithApple state");
                NSLog(@"%@", errorMsg);
            });
        }];
    } else {
        return false;
    }
    
    //    FBSDKAccessToken *token = [PFFacebookPrivateUtilities facebookAccessTokenFromUserAuthenticationData:authData];
//    if (!token) {
//        return !authData; // Only deauthenticate if authData was nil, otherwise - return failure (`NO`).
//    }
//
//    FBSDKAccessToken *currentToken = [FBSDKAccessToken currentAccessToken];
//    // Do not reset the current token if we have the same token already set.
//    if (![currentToken.userID isEqualToString:token.userID] ||
//        ![currentToken.tokenString isEqualToString:token.tokenString]) {
//        [FBSDKAccessToken setCurrentAccessToken:token];
//    }
    
    return YES;
}



@end
