//
//  AppDelegate.m
//  NSStatusItemExample
//
//  Created by Tim Jarratt on 3/31/13.
//  Copyright (c) 2013 Tim Jarratt. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

#pragma mark - lifecycle
- (void) awakeFromNib {
    
    eyeIsClosed = (BOOL)[runCommand(@"defaults read com.apple.finder AppleShowAllFiles")
                   isEqualToString:@"FALSE\n"];

    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: 20];
    [statusItem setHighlightMode:NO];
    
    (eyeIsClosed) ? [self closeEye] : [self openEye];

    [statusItem setAction:@selector(changeIcon:)];
    
    [NSApp activateIgnoringOtherApps:YES];
}

- (void) dealloc {
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
}

- (void)changeIcon:(id)sender {
    (eyeIsClosed) ? [self showHiddenFiles] : [self hideHiddenFiles];
}

- (void)openEye{
    eyeIsClosed = NO;
    NSString* imageName = [[NSBundle mainBundle] pathForResource:@"eye_open_17" ofType:@"png"];
    NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
    [statusItem setImage:imageObj];
}

- (void)showHiddenFiles{
    runCommand(@"defaults write com.apple.finder AppleShowAllFiles TRUE;killall Finder;open -a Finder ~/");
    [self openEye];
}

- (void)hideHiddenFiles{
    runCommand(@"defaults write com.apple.finder AppleShowAllFiles FALSE;killall Finder;open -a Finder ~/");
    [self closeEye];
}

- (void)closeEye{
    eyeIsClosed = YES;
    NSString* imageName = [[NSBundle mainBundle] pathForResource:@"eye_closed_17" ofType:@"png"];
    NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
    [statusItem setImage:imageObj];
}

NSString *runCommand(NSString *commandToRun){
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command: %@",commandToRun);
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return output;
}

@end
