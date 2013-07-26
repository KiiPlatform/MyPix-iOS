//
//  KiiSocialConnect.h
//  KiiSDK-Private
//
//  Created by Chris Beauchamp on 7/3/12.
//  Copyright (c) 2012 Kii Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KiiSocialConnectNetwork;
@class KiiSCNFacebook;

typedef enum {
    kiiSCNFacebook
} KiiSocialNetworkName;

/** An interface to link users to social networks
 
 The SDK currently support the following social networks (KiiSocialNetworkName constant):
  
 1. Facebook (kiiSCNFacebook)
*/
@interface KiiSocialConnect : NSObject;


/** Required method by KiiSocialNetwork
 
 This method must be placed in your AppDelegate file in order for the SNS to properly authenticate with KiiSocialConnect:

    // Pre iOS 4.2 support
    - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
        return [KiiSocialConnect handleOpenURL:url];
    }
 
    // For iOS 4.2+ support
    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
                                           sourceApplication:(NSString *)sourceApplication 
                                                  annotation:(id)annotation {
        return [KiiSocialConnect handleOpenURL:url];
    }

 */
+ (BOOL) handleOpenURL:(NSURL*)url;


/** Set up a reference to one of the supported KiiSocialNetworks.
 
 The user will not be authenticated or linked to a <KiiUser>
 until one of those methods are called explicitly.
 @param network One of the supported KiiSocialNetworkName values
 @param key The SDK key assigned by the social network provider
 @param secret The SDK secret assigned by the social network provider
 @param options Extra options that should be passed to the SNS. Examples could be (Facebook) an NSDictionary of permissions to grant to the authenticated user.
 */
+ (void) setupNetwork:(KiiSocialNetworkName)network 
              withKey:(NSString*)key 
            andSecret:(NSString*)secret 
           andOptions:(NSDictionary*)options;


/** Log a user into the social network provided
 
 This will initiate the login process for the given network, which for SSO-enabled services like Facebook, will send the user to the Facebook app for authentication. If a <KiiUser> has already been authenticated, this will authenticate and link the user to the network. Otherwise, this will generate a <KiiUser> that is automatically linked to the social network. The network must already be set up via <setupNetwork:withKey:andSecret:andOptions:>
 @param network One of the supported KiiSocialNetworkName values
 @param options A dictionary of key/values to pass to KiiSocialConnect
 @param delegate The object to make any callback requests to
 @param callback The callback method to be called when the request is completed. The callback method should have a signature similar to:
 
     - (void) loggedIn:(KiiUser*)user usingNetwork:(KiiSocialNetworkName)network withError:(NSError*)error {
         
         // the process was successful - the user is now authenticated
         if(error == nil) {
             // do something with the user
         }
         
         else {
             // there was a problem
         }
     }
 
 */
+ (void) logIn:(KiiSocialNetworkName)network usingOptions:(NSDictionary*)options withDelegate:(id)delegate andCallback:(SEL)callback;


/** Link the currently logged in user with a social network
 
 This will initiate the login process for the given network, which for SSO-enabled services like Facebook, will send the user to the Facebook app for authentication. There must be a currently authenticated <KiiUser>. Otherwise, you can use the logIn: method to create and log in a <KiiUser> using Facebook. The network must already be set up via <setupNetwork:withKey:andSecret:andOptions:>
 @param network One of the supported KiiSocialNetworkName values
 @param options A dictionary of key/values to pass to KiiSocialConnect
 @param delegate The object to make any callback requests to
 @param callback The callback method to be called when the request is completed. The callback method should have a signature similar to:
 
     - (void) userLinked:(KiiUser*)user withNetwork:(KiiSocialNetworkName)network andError:(NSError*)error {
         
         // the process was successful - the user is now linked to the network
         if(error == nil) {
             // do something with the user
         }
         
         else {
             // there was a problem
         }
     }
 
 */
+ (void) linkCurrentUserWithNetwork:(KiiSocialNetworkName)network
                       usingOptions:(NSDictionary*)options
                       withDelegate:(id)delegate
                        andCallback:(SEL)callback;


/** Unlink the currently logged in user from the social network.
 
 The network must already be set up via <setupNetwork:withKey:andSecret:andOptions:>
 @param network One of the supported KiiSocialNetworkName values
 @param delegate The object to make any callback requests to
 @param callback The callback method to be called when the request is completed. The callback method should have a signature similar to:
 
     - (void) userUnLinked:(KiiUser*)user fromNetwork:(KiiSocialNetworkName)network withError:(NSError*)error {
         
         // the process was successful - the user is no longer linked to the network
         if(error == nil) {
             // do something with the user
         }
         
         else {
             // there was a problem
         }
     }
 
 */
+ (void) unLinkCurrentUserWithNetwork:(KiiSocialNetworkName)network
                         withDelegate:(id)delegate
                          andCallback:(SEL)callback;



/** Retrieve the current user's access token from a social network
 
 The network must be set up and linked to the current user. It is recommended you save this to preferences for multi-session use.
 @param network One of the supported KiiSocialNetworkName values
 @return An NSString representing the access token, nil if none available
 */
+ (NSString*) getAccessTokenForNetwork:(KiiSocialNetworkName)network;



/** Retrieve the current user's access token expiration date from a social network
 
 The network must be set up and linked to the current user. It is recommended you save this to preferences for multi-session use.
 @param network One of the supported KiiSocialNetworkName values
 @return An NSDate representing the access token's expiration date, nil if none available
 */
+ (NSDate*) getAccessTokenExpiresForNetwork:(KiiSocialNetworkName)network;

@end
