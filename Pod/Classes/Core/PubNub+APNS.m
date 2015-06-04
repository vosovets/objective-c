/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+APNS.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNHelpers.h"


#pragma mark Protected interface declaration

@interface PubNub (APNSProtected)


#pragma mark - Push notifications state manipulation 

/**
 @brief  Final designated method which allow to modify push notifications state on set of channels
         for device specified by \c pushToken.
 
 @param shouldEnabled Whether push notification should be enabled or disabled on \c channels.
 @param channels      List of channels for which notification state should be changed.
 @param pushToken     Reference on device push token for which on specified \c channels push
                      notifications will be enabled or disabled.
 @param block         Push notifications state modification on channels processing completion 
                      block which pass only one argument - request processing status to report about
                      how data pushing was successful or not.
 
 @since 4.0
 */
- (void)enablePushNotification:(BOOL)shouldEnabled onChannels:(NSArray *)channels
           withDevicePushToken:(NSData *)pushToken andCompletion:(PNStatusBlock)block;

#pragma mark - 


@end


#pragma mark - Interface implementation

@implementation PubNub (APNS)


#pragma mark - Push notifications state manipulation

- (void)addPushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                         andCompletion:(PNStatusBlock)block {
    
    [self enablePushNotification:YES onChannels:channels withDevicePushToken:pushToken
                   andCompletion:block];
}

- (void)removePushNotificationsFromChannels:(NSArray *)channels
                        withDevicePushToken:(NSData *)pushToken
                              andCompletion:(PNStatusBlock)block {
    
    [self enablePushNotification:NO onChannels:channels withDevicePushToken:pushToken
                   andCompletion:block];
}

- (void)removeAllPushNotificationsFromDeviceWithPushToken:(NSData *)pushToken
                                            andCompletion:(PNStatusBlock)block {
    
    [self enablePushNotification:NO onChannels:nil withDevicePushToken:pushToken
                   andCompletion:block];
}

- (void)enablePushNotification:(BOOL)shouldEnabled onChannels:(NSArray *)channels
           withDevicePushToken:(NSData *)pushToken andCompletion:(PNStatusBlock)block {

    BOOL removeAllChannels = (!shouldEnabled && channels == nil);
    PNOperationType operationType = PNRemoveAllPushNotificationsOperation;
    PNRequestParameters *parameters = [PNRequestParameters new];
    if ([pushToken length]) {

        [parameters addPathComponent:[[PNData HEXFromDevicePushToken:pushToken] lowercaseString]
                      forPlaceholder:@"{token}"];
    }

    if (!removeAllChannels){

        operationType = (shouldEnabled ? PNAddPushNotificationsOnChannelsOperation :
                         PNRemovePushNotificationsFromChannelsOperation);
        if ([channels count]) {

            [parameters addQueryParameter:[PNChannel namesForRequest:channels]
                             forFieldName:(shouldEnabled ? @"add":@"remove")];
        }

        DDLogAPICall(@"<PubNub> %@ push notifications for device '%@': %@.",
                (shouldEnabled ? @"Enable" : @"Disable"),
                [[PNData HEXFromDevicePushToken:pushToken] lowercaseString],
                [PNChannel namesForRequest:channels]);
    }
    else {

        DDLogAPICall(@"<PubNub> Disable push notifications for device '%@'.",
                [[PNData HEXFromDevicePushToken:pushToken] lowercaseString]);
    }

    PNStatusBlock blockCopy = [block copy];
    __weak __typeof(self) weakSelf = self;
    [self processOperation:operationType withParameters:parameters
           completionBlock:^(PNStatus *status){

        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil'
        // object method. This instance is one of client properties and if client
        // already deallocated there is no need to this object which will be
        // deallocated as well.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
        [weakSelf callBlock:blockCopy status:YES withResult:nil andStatus:status];
        #pragma clang diagnostic pop
    }];
}


#pragma mark - Push notifications state audit

- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                                                andCompletion:(PNCompletionBlock)block {

    PNRequestParameters *parameters = [PNRequestParameters new];
    if ([pushToken length]) {

        [parameters addPathComponent:[[PNData HEXFromDevicePushToken:pushToken] lowercaseString]
                      forPlaceholder:@"{token}"];
    }

    DDLogAPICall(@"<PubNub> Push notification enabled channels for device '%@'.",
            [[PNData HEXFromDevicePushToken:pushToken] lowercaseString]);

    PNCompletionBlock blockCopy = [block copy];
    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNPushNotificationEnabledChannelsOperation withParameters:parameters
           completionBlock:^(PNResult *result, PNStatus *status){

               // Silence static analyzer warnings.
               // Code is aware about this case and at the end will simply call on 'nil'
               // object method. This instance is one of client properties and if client
               // already deallocated there is no need to this object which will be
               // deallocated as well.
               #pragma clang diagnostic push
               #pragma clang diagnostic ignored "-Wreceiver-is-weak"
               #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
               [weakSelf callBlock:blockCopy status:NO withResult:result andStatus:status];
               #pragma clang diagnostic pop
           }];
}

#pragma mark -


@end