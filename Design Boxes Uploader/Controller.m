//
//  Controller.m
//  Design Boxes Uploader
//
//  Created by Mike Brand on 6/08/11.
//  Copyright 2011 None. All rights reserved.
//
#import "EMKeychainItem.h"
#import "Controller.h"
#import "Project.h"
#import "ListOfProjects.h"
#import "DDHotKeyCenter.h"
#import "SBJson.h"
#import "AFHTTPRequestOperation.h"

@implementation Controller
@synthesize okButton = _okButton;
@synthesize detailsWindow = _detailsWindow;
@synthesize passwordField = _passwordField;
@synthesize usernameField = _usernameField;
//@synthesize comment = _comment;
@synthesize page = _page;
@synthesize project = _project;
@synthesize theMenu = _theMenu;

@synthesize window = _window;
@synthesize _listOfProjects;
@synthesize _currentProject;
@synthesize _currentPage;
@synthesize folderManager =_folderManager;
@synthesize preview_1 = _preview_1;
@synthesize preview_2 = _preview_2;
@synthesize preview_3 = _preview_3;
@synthesize preview_4 = _preview_4;
@synthesize preview_5 = _preview_5;
@synthesize preview_6 = _preview_6;
@synthesize grab_Screen = _grab_Screen;
@synthesize screenGrabCount;
@synthesize listOfImageURLs;
@synthesize receivedData;
@synthesize restClient;
@synthesize project_id, page_id;


- (id)initWithContent:(id)content {
    self = [super initWithContent:content];
    if (self) {
        [self setup];        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];        
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];        
    }
    
    return self;
}


- (void)setup {
// Attempt at creating a menu bar icon
//    NSStatusBar *bar = [NSStatusBar systemStatusBar];
//    NSStatusItem *designBoxDrop = [bar statusItemWithLength:NSSquareStatusItemLength];
//    NSImage *statusBarIcon = [[NSImage alloc] initByReferencingFile:@"icon.png"]; 
//    [designBoxDrop setImage:statusBarIcon];
//    [designBoxDrop setMenu:_theMenu];
    
    
    
    //[_window makeFirstResponder:_project];
    
    
    

}

-(void)awakeFromNib{
    
    //[EMGenericKeychainItem addGenericKeychainItemForService:@"Design Box" withUsername:@"mikebrand" password:@"abc"];
    restClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://designbox.es/api/"]];
    
    if(![EMGenericKeychainItem genericKeychainItemForService:@"Design Box" withUsername:@"username"] || ![EMGenericKeychainItem genericKeychainItemForService:@"Design Box" withUsername:@"password"]){
        [_detailsWindow makeKeyAndOrderFront:self];
        
    } else {
        [self getProjectsAndPages];
    }
    
    
    
    
    //NSlog(@"item at location %@",[[_popProject itemAtIndex:0] title]);
    
    //Getting the API Stuff Ready
    
    
//    [restClient getPath:@"/get_projects_pages" parameters:nil success:^(id response) {
//        [delegate api:self didLoadTasks:response];
//    } failure:^(NSError *error) {
//        if ([error code] == -1011) {
//            [delegate api:self didFailToLoadTasks:NOT_AUTHENTICATED];
//        } else if ([error code] == -1009) {
//            [delegate api:self didFailToLoadTasks:CONNECTION_FAILED];
//        } else {
//            NSLog(@"%@", [error description]);
//            [delegate api:self didFailToLoadTasks:INVALID_RESPONSE];
//        }
//    }];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //Universal Hotkey
    DDHotKeyCenter * designBoxHotKey =[[DDHotKeyCenter alloc] init];
    [designBoxHotKey registerHotKeyWithKeyCode:0x4
                                 modifierFlags:NSCommandKeyMask | NSAlternateKeyMask
                                        target:self
                                        action:@selector(getScreenAndUpdateView:)
                                        object:nil];
    //Getting things ready for tracking screen grabs
    screenGrabCount = 0;
    listOfImageURLs = [[NSMutableArray alloc] init];
    NSLog(@"Screen Grab Count: %ld", screenGrabCount);
    
    //Make sure there is a temp folder
    folderManager = [[NSFileManager alloc] init];
    NSLog(@"%@", folderManager);
    NSString *tempFolderPath = [[NSString alloc] initWithFormat:@"~/Library/Application Support/Design Box"];
    BOOL tmp = YES;
    BOOL folderExists = [folderManager fileExistsAtPath:[tempFolderPath stringByExpandingTildeInPath]isDirectory:&tmp];
    NSLog(@"It exists %@",  folderExists?@"YES":@"NO");
    
    if (!folderExists) {
        NSLog(@"Making Folders");
        [folderManager createDirectoryAtPath:[tempFolderPath stringByExpandingTildeInPath] withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    
    _listOfProjects = [[ListOfProjects alloc] init];
    
    
       
    
    //ading things to an array which willbecome the ListOfProjects
    NSMutableArray *list = [[NSMutableArray alloc] init];
//    [list addObject:projectRoof];
//    [list addObject:projectMeow];
//    [list addObject:projectNoise];
    
    //sets the ListOfProjects object's array to be actual projects
    [_listOfProjects setListOfProjects:list];
}

-(void)getShareLink{
    
    
}

-(void)getProjectsAndPages{
    NSString * username = [EMGenericKeychainItem genericKeychainItemForService:@"Design Box" withUsername:@"username"].password;
    NSString * password = [EMGenericKeychainItem genericKeychainItemForService:@"Design Box" withUsername:@"password"].password;
    
    [restClient setAuthorizationHeaderWithUsername:username password:password];
    [restClient getPath:@"get_projects_pages" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //succeeded
        
        NSString *dataFromServer = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"You got dem projects %@",dataFromServer);
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *objects = [parser objectWithString:dataFromServer error:nil];
        NSMutableArray *allProjectNames = [[objects allKeys] mutableCopy]; 
        for (int i=0; i < [allProjectNames count]; i++) {
            if([[objects objectForKey:[allProjectNames objectAtIndex:i]] count] > 0) {
                Project *newProject = [[Project alloc] init];
                [newProject setName:[allProjectNames objectAtIndex:i]];
                for (id pageDetailsDictionary in [objects objectForKey:[allProjectNames objectAtIndex:i]]) {
                    Page *newPage = [[Page alloc] init];
                    [newPage setName:[pageDetailsDictionary objectForKey:@"name"]];
                    [newPage setPage_id:[pageDetailsDictionary objectForKey:@"page_id"]];
                    [newProject addPageToProject:newPage];
                }
                [_listOfProjects addProjectToList:newProject];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //failed
        NSLog(@"FAILED");
    }];
    
}

//Number of items in the combo box
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    if (aComboBox == _project) {
        NSLog(@"Number of items in Project");
        return [[_listOfProjects listOfProjects] count];
    } else{
        
        if (_currentProject != nil) {
            NSLog(@"count: %lx",[[_currentProject pages] count]);
            return [[_currentProject pages] count];
            
        } else {
            return 1;
        }
    }
}


- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)loc {
//    NSLog(@"String Value %@", [aComboBox stringValue]);
    if (aComboBox == _project) {
        return [[[_listOfProjects listOfProjects] objectAtIndex:loc] name];
    } else {
        if (_currentProject != nil) {
            if([[_currentProject pages] count] > loc) {
                return [[[_currentProject pages] objectAtIndex:loc] name];
            } else {
                return @"";
            }
        } else {
            return @"Please Select a Project";
        }
    }
}

//- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string {
//    return [[_listOfProjects listOfProjects] indexOfObject: string];
//}

- (void)comboBoxWillDismiss:(NSNotification *)notification {
    NSLog(@"ABOUT TO DISMISS FUCKER");
}

- (void)comboBoxWillPopUp:(NSNotification *)notification {
    NSLog(@"STARTING");
    NSLog(@"ENDING");
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification{
    NSLog(@"CHANGED FUCKER");
    if ([notification object] == _project) {
        _currentProject = [[_listOfProjects listOfProjects] objectAtIndex:[_project indexOfSelectedItem]];
        [_page selectItemAtIndex:0];
        _currentPage = nil;
        [_page reloadData];
    } else {
        _currentPage = [[_currentProject pages] objectAtIndex:[_page indexOfSelectedItem]];
        NSLog(@"the current selected page is %@, which has the ID %@", [_currentPage name],[_currentPage page_id] );
    }
    
}

- (void)comboBoxSelectionIsChanging:(NSNotification *)notification{
    if ([notification object] == _project) {
        NSLog(@"Notification Project %ld",[_project indexOfSelectedItem]);
    }
    
}


- (IBAction)submitImage:(id)sender{
    
//    if (_currentProject == nil){
//        NSLog(@"Yup, there's no project");
//        NSAlert *alert = [[NSAlert alloc] init];
//        [alert setMessageText:@"Please select a project"];
//        [alert runModal];
//        return;
//    }
    
    //[[NSWorkspace sharedWorkspace] openFile:@"/Users/mikebrand/file.jpg"];
    
    
    //int idx =[_project indexOfSelectedItem];
    //NSLog(@"selected: %d", idx);
    //return;
    NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[[NSWorkspace sharedWorkspace] runningApplications]];
    for (id application in windows) {
        if ([[application localizedName] isEqualToString:@"Photoshop"]) {
            NSLog(@"The current running application is %@",[application localizedName]);
            //[_comment setStringValue:[NSString stringWithFormat:@"You're doing cool stuff with %@", [application localizedName]]];
        }
        
    }
    
    [restClient setAuthorizationHeaderWithUsername:@"mike" password:@"abc123"];
    NSString *fileuploadpath = [[NSString stringWithFormat:@"%@",[listOfImageURLs objectAtIndex:0]] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    NSData *imageData =[[NSData alloc] initWithContentsOfFile:fileuploadpath];
    //NSLog(@"%@",imageData);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[_currentPage page_id], @"page_id", nil];
    NSURLRequest *request = [restClient multipartFormRequestWithMethod:@"POST" path:@"testUploadImage" parameters:params constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"img1" fileName:@"Signin0.png" mimeType:@"image/png"];
        [formData appendString:@"HELLO THERE"];
    }];
    NSLog(@"%@",request);
    //show progress bar
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //hide progress bar
        
        NSString *directory = [[NSString alloc] initWithFormat:@"%@%@",NSHomeDirectory(),@"/Library/Application Support/Design Box"];
        NSLog(@"Directory: %@", directory);
        NSError *error = nil;
        NSLog(@"%@",[folderManager contentsOfDirectoryAtPath:directory error:&error]);
        for (NSString *file in [folderManager contentsOfDirectoryAtPath:directory error:&error]) {
            [folderManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory,file] error:&error];
        }
        [_preview_1 setImage:nil];
        //BLBK
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //hide progress bar with error alert
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    
    
    NSSize size;
    
    size.width = 100.0;
    size.height = 10.0;
    //[[[NSApplication sharedApplication] mainWindow] setIsVisible:FALSE];
    [[NSApplication sharedApplication] hide:self];
    
    
    //NSString *scriptSource = [NSString stringWithFormat:@"tell application \"Safari\" \nmake new document at end of documents \nset URL of document 1 to \"http://designbox.es\" \nend tell"];
    //NSDictionary *errorDict;
    //NSAppleScript *photoshopScript = [[NSAppleScript alloc] initWithSource:scriptSource]; //scriptSource
    //[photoshopScript executeAndReturnError:&errorDict];
    
 

    
    
    
    

     
    
    
    
}

//This function gets the current front window from Photoshop and tells you what file it is. 


- (IBAction)getScreenAndUpdateView:(id)sender{
   
    NSLog(@"hotkey pressed");
    
    NSArray *imageWells = [[NSArray alloc] initWithObjects:_preview_1, _preview_2, _preview_3, _preview_4, _preview_5, _preview_6, nil];
    
    NSInteger *photoshopTest = 0;
    
    NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[[NSWorkspace sharedWorkspace] runningApplications]];
    for (id application in windows) {
        if ([[application localizedName] isEqualToString:@"Photoshop"]) {
            NSString *scriptSource = [NSString stringWithFormat:@"tell application \"Finder\" \nset savefolder to \"\" & (path to current user folder) & \"Library:Application Support:Design Box:\" \nend tell \ntell application \"Adobe Photoshop CS5\" \nactivate \nset theDocument to name of current document  \nset tid to AppleScript's text item delimiters \nset AppleScript\'s text item delimiters to \".\" \nset theDocument to text item 1 of theDocument \nset AppleScript\'s text item delimiters to tid \nexport current document in (\"\" & savefolder & theDocument & \".png\") as save for web with options {transparency:false} \nreturn (\"/Volumes/\" & savefolder & theDocument & \".png\") \nend tell"];
          //NSLog(@"File: %@", scriptSource);
          
            NSAppleScript *photoshopScript = [[NSAppleScript alloc] initWithSource:scriptSource]; //scriptSource
            NSLog(@"A");
            NSDictionary * err;
            NSAppleEventDescriptor * execution = [photoshopScript executeAndReturnError:&err];
            NSLog(@"B %@",err);
            NSString *filePath = [NSString stringWithFormat:[execution stringValue]];
            filePath = [filePath stringByReplacingOccurrencesOfString:@"\ " withString:@" "];
            NSLog(@"C");
            filePath = [filePath stringByReplacingOccurrencesOfString:@":" withString:@"/"];
            
            
            NSMutableArray *path = [[NSMutableArray alloc] initWithArray:[filePath pathComponents] copyItems:YES];
            NSString *lastpath = [[path objectAtIndex:[path count]-1] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
            [path replaceObjectAtIndex:[path count]-1 withObject:lastpath];
            
            NSString *filePath1 =[[NSString alloc] initWithFormat:[NSString pathWithComponents:path]];
            
            NSString *fileNameNumber = [[NSString alloc] initWithFormat:@"%ld.",screenGrabCount];
            screenGrabCount +=0;
            NSString *lastpathNumber = [[path objectAtIndex:[path count]-1] stringByReplacingOccurrencesOfString:@"." withString:fileNameNumber];
            [path replaceObjectAtIndex:[path count]-1 withObject:lastpathNumber];
            
            NSString *filePath2 =[[NSString alloc] initWithFormat:[NSString pathWithComponents:path]];
            
            NSLog(@"File Path 1: %@",filePath1);
            NSLog(@"File Path 2: %@",filePath2);
            
            NSError *theError = nil;
            NSLog(@"Folder Manager: %@", folderManager);
            bool success = [folderManager copyItemAtPath:filePath1 toPath:filePath2 error:NULL];
            
            filePath= [NSString pathWithComponents:path];
            NSURL *filePathURL = [[NSURL alloc] initWithString:[filePath stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
            [listOfImageURLs addObject:filePathURL];
            
            //NSLog(@"Photoshop Script Result: %@",filePath);
            //NSURL *imageURL = [[NSURL alloc] initWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
            //NSURL *imageURL = [[NSURL alloc] initWithString:filePath];
            //NSLog(@"The Image URL is: %@",imageURL);
            NSData *imageData=[[NSData alloc] initWithContentsOfFile:filePath];
            //NSLog(@"The Image Data is: %@",imageData);
            //NSImage *img = [[NSImage alloc] initByReferencingFile:filePath];
            NSImage *img = [[NSImage alloc] initWithData:imageData];
            
            
            
            
            //NSLog(@"The Image is: %@",img);
            for (NSImageView *imageWell in imageWells) {
                //if (![imageWell image]) {
                    imageWell.image = img;
                    NSSound *systemSound = [NSSound soundNamed:@"Glass"];
                    [systemSound play];
                    break;
                //}
            }
            
            photoshopTest +=1;
            //NSLog(@"Photoshop Test Number: %ld", photoshopTest);
        }
        
    }
    
    
    
    if (photoshopTest == 0){
        NSLog(@"Make sure photoshop is running.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Make sure photoshop is running."];
        [alert runModal];
        return;
    }

}
 
- (BOOL)fileManager:(NSFileManager *)fileManager shouldMoveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL{
    return YES;
}

//from the NSComboBox Datasource 
//found via http://www.omnigroup.com/mailman/archive/macosx-dev/2002-April/037745.html
- (NSString *)comboBox:(NSComboBox *)comboBox completedString:(NSString
                                                               *)partialString {
    if (comboBox ==  _project) {
        int idx; // loop counter
        for (idx = 0; idx < [[_listOfProjects listOfProjects] count]; idx++) {
            NSString *testItem = [[[_listOfProjects listOfProjects] objectAtIndex:idx] name];
            if ([[testItem commonPrefixWithString:partialString
                                          options:NSCaseInsensitiveSearch] length] == [partialString length]) {
                return testItem;
            }
        }
    } else {
        NSLog(@"A");
        int idx; // loop counter
        NSLog(@"B");
        for (idx = 0; idx < [[_currentProject pages] count]; idx++) {
             NSLog(@"C");
            NSString *testItem = [[[_currentProject pages] objectAtIndex:idx] name];
            NSLog(@"I'm doing character matching number one: %@",testItem);
            if ([[testItem commonPrefixWithString:partialString
                                          options:NSCaseInsensitiveSearch] length] == [partialString length]) {
                return testItem;
            }
        }
    }
    return @"";
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
    NSLog(@"didReceiveData");    
}
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
}

- (IBAction)setUsernameAndPassword:(id)sender {
    [restClient setAuthorizationHeaderWithUsername:_usernameField.stringValue password:_passwordField.stringValue];
    [restClient getPath:@"checkAuth" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS %@",responseObject);
        [self saveUsernameAndPassword];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAIL FAIL FAIL %@", error);
    }];
}

-(void)saveUsernameAndPassword {
    NSLog(@"Meow");
    
    NSString *username = [[NSString alloc] init];
    NSString *password = [[NSString alloc] init];
    
    username = _usernameField.stringValue;
    password = _passwordField.stringValue;
    
    [EMGenericKeychainItem addGenericKeychainItemForService:@"Design Box" withUsername:@"username" password:username];
    [EMGenericKeychainItem addGenericKeychainItemForService:@"Design Box" withUsername:@"password" password:password];
    [self getProjectsAndPages];
    [_detailsWindow close];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %lx bytes of data",[receivedData length]);
    NSString *dataFromServer = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    //NSMutableString *string = [[NSMutableString alloc] initwithData:receivedData encoding:nil];
    NSLog(@"The Result Stuff Is: %@",dataFromServer);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *objects = [parser objectWithString:dataFromServer error:nil];
    NSMutableArray *allProjectNames = [[objects allKeys] mutableCopy];
    
    for (int i=0; i < [allProjectNames count]; i++)
    {
        Project *newProject = [[Project alloc] init];
        [newProject setName:[allProjectNames objectAtIndex:i]];
        
        for (id pageDetailsDictionary in [objects objectForKey:[allProjectNames objectAtIndex:i]]) {
            Page *newPage = [[Page alloc] init];
            [newPage setName:[pageDetailsDictionary objectForKey:@"name"]];
            [newPage setPage_id:[pageDetailsDictionary objectForKey:@"page_id"]];
            [newProject addPageToProject:newPage];
            NSLog(@"********* Name: %@ id: %@",[newPage name],[newPage page_id] );
        }
        
        //[newProject setPages:[objects objectForKey:[allKeys objectAtIndex:i]]];
         
        
        // You can retrieve individual values using objectForKey on the status NSDictionary
        // This will print the tweet and username to the console'
        NSLog(@"Project Name: %@",[newProject name]);
        NSLog(@"Pages Count: %lx",[[newProject pages] count]);
        
        for (id page in [newProject pages]) {
            NSLog(@"Project Pages: %@",[page name]);
        }
        
        [_listOfProjects addProjectToList:newProject];
        
        //NSLog(@"%@ - %@", [object objectForKey:@"text"], [[objects objectForKey:@"user"] objectForKey:@"screen_name"]);
    }
    
//    NSMutableArray *pages;
//    NSString *name;
}

- (BOOL)usesDataSource{
    return YES;
}


- (IBAction)setProjectPagesList:(id)sender {
}


- (IBAction)cancelProjectUpload:(id)sender {
    [[NSApplication sharedApplication] hide:self];
}

- (IBAction)annotateFileForUploading:(id)sender {
}
@end
