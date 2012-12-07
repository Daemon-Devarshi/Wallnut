//
//  DKAppDelegate.m
//  Wallnut
//
//  Created by Devarshi Kulshreshtha on 11/05/12.
//  Copyright (c) 2012 DaemonConstruction. All rights reserved.
//

#import "DKAppDelegate.h"
#import "URLStringTransformer.h"
#import "NSArray+StringElementsAdditions.h"

#define doNotchangeWallpaperForImageOnApplicationLaunch NO
#define changeWallpaperForImageOnKeyValueChange    YES

@interface DKAppDelegate ()
@property (strong, readwrite) NSTimer *imageChangeTimer;
@property (strong, readwrite) NSArray *imageFilesPathsInSelectedDirectory;
@property (strong, readwrite) NSArray *timeIntervalArray;

// in below method conditionFlag is added because
// the same method is called when application is launched
// and when value for key conditionFlag is changed
// and it makes no sense to change wallpaper image if some image is set as its value
- (void)changeImageAccordingToFileOrFolderPath:(NSString *)fileFolderPath allowForImagePath:(BOOL)isWallpaperChangeAllowedForImagePath;

- (void)changeDesktopImageFromSelectedFolderUsingTimer:(NSTimer *)aTimer;
- (NSArray *)imageFilesPathsFromDirectoryPath:(NSString *)aDirectoryPath;
- (NSURL *)randomImageURL;
- (void)timeIntervalMenuItemAction:(id)sender;
@end

@implementation DKAppDelegate

@synthesize window = _window;
@synthesize currentDesktopImageURL = _currentDesktopImageURL;
@synthesize imageChangeTimer = _imageChangeTimer;
@synthesize imageFilesPathsInSelectedDirectory =_imageFilesPathsInSelectedDirectory;
@synthesize timeIntervalArray =_timeIntervalArray;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    // adding self as observer for keys in standard user defaults
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"fileFolderPath" options:NSKeyValueObservingOptionNew context:NULL];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"imageChangeInterval" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"currentDesktopImageURL" options:NSKeyValueObservingOptionNew context:NULL];
    
    // invoking method so that when application is launched it can change wallpaper
    [self changeImageAccordingToFileOrFolderPath:[[NSUserDefaults standardUserDefaults] objectForKey:@"fileFolderPath"] allowForImagePath:doNotchangeWallpaperForImageOnApplicationLaunch];
    
    //defining an array of time interval
    NSNumber *fifteenSecsInterval = [NSNumber numberWithInt:15];
    NSNumber *thirtySecsInterval  = [NSNumber numberWithInt:30];
    NSNumber *sixtySecsInterval   = [NSNumber numberWithInt:60];
    self.timeIntervalArray = [[NSArray alloc] initWithObjects:fifteenSecsInterval,thirtySecsInterval,sixtySecsInterval,nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fileFolderPath"] && [object isEqual:[NSUserDefaults standardUserDefaults]]) 
    {
        // obtain new path
        NSString *fileFolderPath = [change objectForKey:NSKeyValueChangeNewKey];
        
        [self changeImageAccordingToFileOrFolderPath:fileFolderPath allowForImagePath:changeWallpaperForImageOnKeyValueChange];
    }
    else if ([keyPath isEqualToString:@"currentDesktopImageURL"] && [object isEqual:self]) 
    {
        NSError *error = nil;
        NSDictionary *optionsDictionary = @{NSWorkspaceDesktopImageScalingKey : @2, NSWorkspaceDesktopImageFillColorKey : [NSColor blackColor]};
        [[NSWorkspace sharedWorkspace] setDesktopImageURL:[change objectForKey:NSKeyValueChangeNewKey] 
                                                forScreen:[NSScreen mainScreen] 
                                                  options:optionsDictionary 
                                                    error:&error];
    }
    else if ([keyPath isEqualToString:@"imageChangeInterval"] && [object isEqual:[NSUserDefaults standardUserDefaults]]) 
    {
        // time interval is changed
        // so simply invoke below method to invalidate timer
        // and create a new one according to changed interval
        [self changeImageAccordingToFileOrFolderPath:[[NSUserDefaults standardUserDefaults] objectForKey:@"fileFolderPath"]  allowForImagePath:NO];
    }
}
- (void)changeImageAccordingToFileOrFolderPath:(NSString *)fileFolderPath allowForImagePath:(BOOL)isWallpaperChangeAllowedForImagePath
{
    //Check if path changed is of file or directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    
    if (self.imageChangeTimer) {
        // invalidate existing timer
        [self.imageChangeTimer invalidate];
    }
    
    if ([fileManager fileExistsAtPath:fileFolderPath isDirectory:&isDir] && isDir) {
        // directory found
        
        // retreive image files from directory and store it in imageFilesPathsInSelectedDirectory
        self.imageFilesPathsInSelectedDirectory = [self imageFilesPathsFromDirectoryPath:fileFolderPath];
        
        // start a new timer
        NSTimeInterval repeatInterval;
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"imageChangeInterval"]) {
            // no interval found
            // by default take it to be 15 secs
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:15] forKey:@"imageChangeInterval"];
            
        }
        
        repeatInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"imageChangeInterval"] doubleValue];
        
        self.imageChangeTimer = [NSTimer scheduledTimerWithTimeInterval:repeatInterval
                                                                 target: self
                                                               selector:@selector(changeDesktopImageFromSelectedFolderUsingTimer:)
                                                               userInfo: nil
                                                                repeats:YES];
    }
    else
    {
        if (isWallpaperChangeAllowedForImagePath) {
            // file found
            // change currentDesktopImageURL
            URLStringTransformer *urlToStringTransformer = [[URLStringTransformer alloc] init];
            self.currentDesktopImageURL = [urlToStringTransformer reverseTransformedValue:fileFolderPath];
        }
        
    }

}
- (NSArray *)imageFilesPathsFromDirectoryPath:(NSString *)aDirectoryPath
{
    // obtaining image file names in the directory
    
    //FIXME: these can be obtained from Wallnut-Info.plist
    NSArray *imageFileExtensions = [[NSArray alloc] initWithObjects:@"png",@"jpg",@"jpeg", nil];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:aDirectoryPath error:&error];
    NSArray *imageFiles = [directoryContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension IN %@",imageFileExtensions]];
    
    // prefixing directory path to file names
    return [imageFiles addPrefix:[aDirectoryPath stringByAppendingString:@"/"]];
}
- (void)changeDesktopImageFromSelectedFolderUsingTimer:(NSTimer *)aTimer
{
    self.currentDesktopImageURL = [self randomImageURL];
}
- (NSURL *)randomImageURL
{
    NSInteger imageIndex = arc4random() % [self.imageFilesPathsInSelectedDirectory count];
    
    return [NSURL fileURLWithPath:[self.imageFilesPathsInSelectedDirectory objectAtIndex:imageIndex]];
}
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    // change path from NSURL to NSString
    
    // store changed path in standard user defaults
    [[NSUserDefaults standardUserDefaults] setObject:filename forKey:@"fileFolderPath"];
    
    return NO;
}

#pragma mark showing menu in dock icon and associated methods
- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    NSMenu *menuToReturn = [[NSMenu alloc] initWithTitle:@"menuToReturn"];
    
    // if fileFolderPath represents a directory path
    // then only show the dock icon menu
    // otherwise don't show
    if ([fileManager fileExistsAtPath:[[NSUserDefaults standardUserDefaults] objectForKey:@"fileFolderPath"] isDirectory:&isDir] && isDir) {
        NSMenuItem *repeatAfterSecsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Repeat After Secs" action:NULL keyEquivalent:@""];
        
        [menuToReturn addItem:repeatAfterSecsMenuItem];
        
        NSMenu *timeIntervalMenu = [[NSMenu alloc] initWithTitle:@"timeIntervalMenu"];
        
        for (id timeInterval in self.timeIntervalArray)
        {
            NSMenuItem *timeIntervalMenuItem = [[NSMenuItem alloc] initWithTitle:[timeInterval stringValue] action:@selector(timeIntervalMenuItemAction:) keyEquivalent:@""];
            [timeIntervalMenuItem setRepresentedObject:timeInterval];
            [timeIntervalMenu addItem:timeIntervalMenuItem];
        }
        
        [menuToReturn setSubmenu:timeIntervalMenu forItem:repeatAfterSecsMenuItem];
    }
    
    return menuToReturn;
}
- (void)timeIntervalMenuItemAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[sender representedObject] forKey:@"imageChangeInterval"];
}
@end
