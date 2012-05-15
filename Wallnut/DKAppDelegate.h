
//
//  DKAppDelegate.h
//  Wallnut
//
//  Created by Devarshi Kulshreshtha on 11/05/12.
//  Copyright (c) 2012 DaemonConstruction.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DKAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (strong, readwrite) NSURL *currentDesktopImageURL;
@end
