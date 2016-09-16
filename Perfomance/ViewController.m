//
//  ViewController.m
//  Perfomance
//
//  Created by jinren on 9/15/16.
//  Copyright © 2016 jinren. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *viewS;
@property (nonatomic, strong) NSString* strLog;
@end

@implementation ViewController

NSInteger counterl = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIdleNoti:) name:@"MyIdleNotification" object:nil];
    
    self.strLog = @"******strLog******";
/*****************************************************
 Observer useage
    [self startInstallRunLoopObserver];
 *****************************************************/


//1. timer won't stop when scrollview, as the timer is on the other thread(not the same as scroll view).
//2. timer will be ignored as time is in default mode and when scroll view, runloop will run in Commond Mode.
/******************************************
 perform selector
****************************************************/

    NSThread *thread = [self startRunLoop];
    NSLog(@"Selector start :%@", [NSDate date]);
    [self performSelectorOnMainThread:@selector(selectPerformRun:) withObject:self waitUntilDone:NO];
    NSLog(@"Selector end :%@", [NSDate date]);
/*****************************************************
 end perform selector
 *****************************************************/
 
/***************************************************
 difference between commonModes and DefaultMode about timer
****************************************************/
    //this timer will stop when scrollview
    self.viewS.contentSize = CGSizeMake(300, 1000);
    NSTimer* ti =  [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"mainthread block time fired ...");
        self.counterLabel.text = [NSString stringWithFormat:@"%ld", counterl];
        counterl++;
    }];
    
    //scroll view will not interrupt timer in commonModes
//    [[NSRunLoop currentRunLoop] addTimer:ti forMode:NSRunLoopCommonModes];
    //scroll view will sto the timer on the defaultMode
//    [[NSRunLoop currentRunLoop] addTimer:ti forMode:NSDefaultRunLoopMode];

}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear start ...");
    [super viewWillAppear:animated];
    NSMutableArray* arrayData = [NSMutableArray arrayWithCapacity:1000];
    for (int i = 0 ; i < 1000; i++) {
        [arrayData addObject:[NSString stringWithFormat:@"string:%d",i]];
    }
    NSLog(@"viewWillAppear end ...");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)postNotify
{
    NSString *strNoti = @"stringNoti_now";
    NSNotification* myNotification = [NSNotification notificationWithName:@"MyIdleNotification" object:strNoti];
    //first arrived
    [[[NSNotificationQueue alloc] initWithNotificationCenter:[NSNotificationCenter defaultCenter] ]  enqueueNotification:myNotification postingStyle:NSPostNow];
    //the second arrived
    NSNotification* myNotification1 = [NSNotification notificationWithName:@"MyIdleNotification" object:@"stringNoti_asap"];
    [[NSNotificationQueue defaultQueue] enqueueNotification:myNotification1 postingStyle:NSPostASAP];
    //last arrived
    NSNotification* myNotification2 = [NSNotification notificationWithName:@"MyIdleNotification" object:@"stringNoti_idle"];
    [[NSNotificationQueue defaultQueue] enqueueNotification:myNotification2 postingStyle:NSPostWhenIdle];

}

- (void)handleIdleNoti:(NSNotification *)noti
{
    NSLog(@"***hanlde Idle Noti:%@", noti.object);
    
}

//typedef void (*CFRunLoopObserverCallBack)(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);

NSUInteger num = 0;
void myCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    ViewController* vc = (__bridge ViewController*)info;
    NSLog(@"callback:%@", vc.strLog);
    
}

void myCallback1(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{

    NSLog(@"    callback111");
    
}

void myCallback2(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    NSLog(@"        callback222");
    
}

- (void)startInstallRunLoopObserver
{
    CFRunLoopObserverRef ref = NULL;
    //warning the activities type
    
    ref = CFRunLoopObserverCreate(NULL, kCFRunLoopBeforeWaiting| kCFRunLoopAfterWaiting, YES, 10, &myCallback, (void*)self);
    
    if (ref) {
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), ref, kCFRunLoopCommonModes);
    }
    
    ref = CFRunLoopObserverCreate(NULL, kCFRunLoopBeforeSources, YES, 10, &myCallback1, (void*)self);
    if (ref) {
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), ref, kCFRunLoopCommonModes);
    }

    ref = CFRunLoopObserverCreate(NULL, kCFRunLoopBeforeTimers, YES, 10, &myCallback2, (void*)self);
    if (ref) {
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), ref, kCFRunLoopCommonModes);
    }

}

- (NSThread *)startRunLoop
{
    NSThread* thre = [[NSThread alloc] initWithTarget:self selector:@selector(threadProc:) object:nil];
    [thre start];
    return thre;
}


- (void)threadProc:(id)object
{
    NSLog(@"thread entry");
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"threadProc  block  time fired...%lu", counterl);
        self.counterLabel.text = [NSString stringWithFormat:@"%ld", counterl];
        counterl++;
    }];
    
    do
    {
        [runloop run];
    }
    while (YES);
    
}

- (void)selectPerformRun:(ViewController*)vc
{
    NSLog(@"start selectPerformRun : %@", vc.strLog);
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10000];
    
    for (NSInteger i = 0; i < 10000; i++) {
        [arr addObject:[NSString stringWithFormat:@"fewafefadsfasdf:%ld", i]];
    }
    NSLog(@"end selectPerformRun : %@", vc.strLog);
}

@end
