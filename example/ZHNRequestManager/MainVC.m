//
//  MainVC.m
//  ZHNRequestManager
//
//  Created by vi on 14/05/2015.
//
//

#import "MainVC.h"
#import "MainRM.h"

@interface MainVC ()

@property (nonatomic, strong) MainRM* mainRM;

@end

@implementation MainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mainRM = [MainRM new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successHandler:) name:kRequestSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failHandler:) name:kRequestFail object:nil];
}




#pragma mark - handlers

- (IBAction)loadHandler:(id)sender
{
    [self.mainRM loadDataForce:YES params:nil];
}

- (void) successHandler:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void) failHandler:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}



@end
