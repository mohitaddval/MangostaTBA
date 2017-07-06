//
//  XMPPTBReconnection.h
//  XMPPFramework
//
//  Created by Andres Canal on 7/5/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

#import <XMPPFramework/XMPPFramework.h>
#import <XMPPFramework/XMPPIDTracker.h>

@interface XMPPTBReconnection : XMPPModule {
	XMPPIDTracker *responseTracker;
}
@property (nonatomic,retain) XMPPStream * _Nullable myStream;
- (void) getAuthToken;
@end

@protocol XMPPTBReconnectionDelegate
- (void)xmppTBReconnection:(nonnull XMPPTBReconnection *)sender didReceiveToken:(nonnull NSDictionary<NSString *, NSString *> *) token;
- (void)xmppTBReconnection:(nonnull XMPPTBReconnection *)sender didFailToReceiveToken:(nonnull XMPPIQ *)iq;
@end
