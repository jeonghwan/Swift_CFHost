//
//  Swift_CFHostDemo-Bridging-HeaderHeader.h
//  Swift_CFHostDemo
//
//  Created by ImJeonghwan on 10/13/16.
//  Copyright © 2016 ImJeonghwan. All rights reserved.
//

#ifndef Swift_CFHostDemo_Bridging_HeaderHeader_h
#define Swift_CFHostDemo_Bridging_HeaderHeader_h

#if TARGET_OS_IPHONE

#import <CFNetwork/CFNetwork.h>

#else

#import <CoreServices/CoreServices.h>

#endif



#import <sys/types.h>

#import <sys/socket.h>

#import <netdb.h>

#endif /* Swift_CFHostDemo_Bridging_HeaderHeader_h */
