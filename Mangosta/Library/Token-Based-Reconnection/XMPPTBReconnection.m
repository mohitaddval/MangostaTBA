//
//  XMPPTBReconnection.m
//  XMPPFramework
//
//  Created by Andres Canal on 7/5/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

#import "XMPPTBReconnection.h"
#import "XMPPFramework.h"
#import "XMPPIQ.h"

@implementation XMPPTBReconnection
@synthesize myStream;
// Token based Authentication (Getting token here)
- (void) getAuthToken {
	//		<iq from='crone1@shakespeare.lit/desktop'
	//			      id='create1'
	//			      to='coven@muclight.shakespeare.lit'
	//			    type='get'>
	//			<query xmlns='erlang-solutions.com:xmpp:token-auth:0'/>
	//		</iq>
     responseTracker = [[XMPPIDTracker alloc] initWithStream:self.myStream dispatchQueue:self.moduleQueue];
    
	dispatch_block_t block = ^{ @autoreleasepool {
		
		NSString *iqID = [myStream generateUUID];
		NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
		[iq addAttributeWithName:@"id" stringValue:iqID];
		[iq addAttributeWithName:@"to" stringValue:self.myStream.myJID.bare];
		[iq addAttributeWithName:@"type" stringValue:@"get"];
		
		NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"msg.kulcare.com:xmpp:token-auth:0"];
		[iq addChild:query];
		
		[responseTracker addID:iqID
						target:self
					  selector:@selector(handleGetAuthToken:withInfo:)
					   timeout:60.0];
		
		[myStream sendElement:iq];
	}};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_async(moduleQueue, block);
}
//Calback to handle response of Token
- (void)handleGetAuthToken:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo>)info {
	if ([[iq type] isEqualToString:@"result"]){
		NSXMLElement *items = [iq elementForName:@"items"];
		
		NSMutableDictionary *tokensDictionary = [[NSMutableDictionary alloc] init];
		for (NSXMLElement *element in items.children) {
			tokensDictionary[element.name] = element.stringValue;
		}
		[multicastDelegate xmppTBReconnection:self didReceiveToken:tokensDictionary];
	}else{
		[multicastDelegate xmppTBReconnection:self didFailToReceiveToken:iq];
	}
}

- (BOOL)activate:(XMPPStream *)aXmppStream {
	if ([super activate:aXmppStream]){
		responseTracker = [[XMPPIDTracker alloc] initWithDispatchQueue:moduleQueue];
		
		return YES;
	}
	return NO;
}
//Always fail here after timeout
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
	NSString *type = [iq type];
	if ([type isEqualToString:@"result"] || [type isEqualToString:@"error"]){
		return [responseTracker invokeForID:[iq elementID] withObject:iq];
	}

	return NO;
}


@end
