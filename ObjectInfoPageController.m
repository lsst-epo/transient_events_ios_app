//
//  ObjectInfoPageController.m
//  Transient Events
//
//  Created by Nathan Fitzgibbon on 12/2/11.
//  Copyright (c) 2011 Diffraction Limited Design LLC. All rights reserved.
//

#import "ObjectInfoPageController.h"
#import "EventListController.h"
#import "EventDetailController.h"
#import "Constants.h"
#import "GlossaryController.h"



@implementation ObjectInfoPageController
@synthesize eventDetails;
@synthesize infoView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle




- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = self.eventDetails;
    
    NSString* path = [[NSBundle mainBundle] pathForResource:self.eventDetails 
                                                     ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.infoView.opaque = NO;
    self.infoView.backgroundColor = [UIColor clearColor];
    self.infoView.textColor = [UIColor darkGrayColor];
    self.infoView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.infoView.userInteractionEnabled = YES;

    
    
    [self.infoView setText:content];
    // Do any additional setup after loading the view from its nib.
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
