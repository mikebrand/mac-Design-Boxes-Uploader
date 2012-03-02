//
//  Controller.h
//  Design Boxes Uploader
//
//  Created by Mike Brand on 6/08/11.
//  Copyright 2011 None. All rights reserved.
//

#import "NSImage+QuickLook.h"
#import "Project.h"
#import "ListOfProjects.h"
#import "NSImage+QuickLook.h"
#import "Page.h"

#import "AFHTTPClient.h"
#import <QuickLook/QuickLook.h>

@interface Controller : NSObjectController <NSComboBoxDelegate, NSFileManagerDelegate, NSURLConnectionDelegate> {
    
    NSWindow *_window;
    
    NSMenu *_theMenu;
    NSComboBox *_project;
    NSComboBox *_page;
    
    //NSTextField *_comment;
    
    ListOfProjects *_listOfProjects;
    Project *_currentProject;
    Page *_currentPage;
    NSImageView *_preview_1;
    NSImageView *_preview_2;
    NSImageView *_preview_3;
    NSImageView *_preview_4;
    NSImageView *_preview_5;
    NSImageView *_preview_6;
    NSButton *_grab_Screen;
    NSFileManager *folderManager;
    NSInteger screenGrabCount;
    NSMutableArray *listOfImageURLs;
    NSMutableData *receivedData;
    AFHTTPClient *restClient;
    NSString *project_id;
    NSString *page_id;
    
    NSWindow *_detailsWindow;
    NSTextField *_usernameField;
    NSSecureTextField *_passwordField;
    NSButton *_okButton;
}

@property (strong) IBOutlet NSWindow *window;



@property (strong) IBOutlet NSComboBox *project;
@property (strong) IBOutlet NSComboBox *page;
//@property (strong) IBOutlet NSTextField *comment;
@property (strong) IBOutlet NSMenu *theMenu;
@property (retain) ListOfProjects *_listOfProjects;
@property (retain) Project *_currentProject;
@property (retain) Page *_currentPage;
@property (retain) NSFileManager *folderManager;
@property (strong) IBOutlet NSImageView *preview_1;
@property (strong) IBOutlet NSImageView *preview_2;
@property (strong) IBOutlet NSImageView *preview_3;
@property (strong) IBOutlet NSImageView *preview_4;
@property (strong) IBOutlet NSImageView *preview_5;
@property (strong) IBOutlet NSImageView *preview_6;
@property (strong) IBOutlet NSButton *grab_Screen;
@property () NSInteger screenGrabCount;
@property (retain) NSMutableArray *listOfImageURLs;
@property (retain) NSMutableData *receivedData;
@property (retain) AFHTTPClient *restClient;
@property (retain) NSString *project_id;
@property (retain) NSString *page_id;

@property (strong) IBOutlet NSTextField *usernameField;
@property (strong) IBOutlet NSSecureTextField *passwordField;
@property (strong) IBOutlet NSWindow *detailsWindow;
@property (strong) IBOutlet NSButton *okButton;



- (IBAction)setProjectPagesList:(id)sender;
- (IBAction)uploadProjectFile:(id)sender;
- (IBAction)cancelProjectUpload:(id)sender;
- (IBAction)annotateFileForUploading:(id)sender;
- (void)comboBoxSelectionDidChange:(NSNotification *)notification;
- (void)comboBoxSelectionIsChanging:(NSNotification *)notification;
- (BOOL)usesDataSource;
- (id)objectValueOfSelectedItem;
- (IBAction)submitImage:(id)sender;
- (void)setup;
- (IBAction)getScreenAndUpdateView:(id)sender;
- (BOOL)fileManager:(NSFileManager *)fileManager shouldMoveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error;
- (IBAction)setUsernameAndPassword:(id)sender;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

-(void)getShareLink;
-(void)getProjectsAndPages;
-(void)saveUsernameAndPassword;
@end
