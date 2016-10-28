//
//  DeviceAdapter.h
//  mobileDeviceManager
//
//  Created by Taras Kalapun on 12.01.11.
//  Copyright 2011 Ciklum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobileDeviceAccess.h"

@class DeviceAdapter;
@class AMDevice;

@protocol DeviceAdapterDelegate <NSObject>

- (void)deviceAdapter:(DeviceAdapter *)DeviceAdapter deviceChanged:(AMDevice *)device;
@end

/*
@protocol
@optional
- (void)deviceConnected:(AMDevice *)device;
@end
*/

@interface DeviceAdapter : NSObject 
<MobileDeviceAccessListener>
{
    AMDevice *iosDevice;
}

@property (nonatomic, retain) AMDevice *iosDevice;

@property (nonatomic, assign) id<DeviceAdapterDelegate> delegate;

- (BOOL)isDeviceConnected;

- (NSString *)getAppIdForName:(NSString *)appName;


@end
