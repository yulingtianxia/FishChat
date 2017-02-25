//
//  FishChat.mm
//  FishChat
//
//  Created by 杨萧玉 on 2017/2/22.
//  Copyright (c) 2017年 __MyCompanyName__. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <CaptainHook/CaptainHook.h>
#import <Cycript/Cycript.h>
#import <UIKit/UIKit.h>

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()

#define CYCRIPT_PORT 8888

//@interface FishChat : NSObject
//
//@end
//
//@implementation FishChat
//
//-(id)init
//{
//	if ((self = [super init]))
//	{
//	}
//
//    return self;
//}
//
//@end


@class ClassToHook;

CHDeclareClass(UIApplication)
CHDeclareClass(MicroMessengerAppDelegate)
CHDeclareClass(CMessageMgr)
CHDeclareClass(FindFriendEntryViewController)
CHDeclareClass(UITabBarItem)

CHOptimizedMethod2(self, void, MicroMessengerAppDelegate, application, UIApplication *, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    CHSuper2(MicroMessengerAppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    NSLog(@"## Start Cycript ##");
    CYListenServer(CYCRIPT_PORT);
}

CHOptimizedMethod1(self, void, CMessageMgr, onRevokeMsg, id, msg)
{
    NSLog(@"onRevokeMsg: msg Class:%@", NSStringFromClass(object_getClass(msg)));
    return;
}

CHOptimizedMethod2(self, CGFloat, FindFriendEntryViewController, tableView, UITableView *, tableView, heightForRowAtIndexPath, NSIndexPath *, indexPath)
{
    NSLog(@"## Hide Time Line Entry ##");
    NSIndexPath *timelineIndexPath = [self valueForKeyPath:@"m_WCTimeLineIndexPath"];
    if (indexPath == timelineIndexPath) {
        return 0;
    }
    return CHSuper2(FindFriendEntryViewController, tableView, tableView, heightForRowAtIndexPath, indexPath);
}

CHOptimizedMethod2(self, UITableViewCell *, FindFriendEntryViewController, tableView, UITableView *, tableView, cellForRowAtIndexPath, NSIndexPath *, indexPath)
{
    NSLog(@"## Hide Time Line Entry ##");
    NSIndexPath *timelineIndexPath = [self valueForKeyPath:@"m_WCTimeLineIndexPath"];
    UITableViewCell *cell = CHSuper2(FindFriendEntryViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (indexPath == timelineIndexPath) {
        cell.hidden = YES;
        for (UIView *subview in cell.subviews) {
            [subview removeFromSuperview];
        }
    }
    return cell;
}

CHPropertySetter(UITabBarItem, setBadgeValue, NSString *, badgeValue)
{
    if (![self.title isEqualToString:@"发现"]) {
        self.badgeValue = badgeValue;
    }
}

CHConstructor // code block that runs immediately upon load
{
	@autoreleasepool
	{
        CHLoadLateClass(MicroMessengerAppDelegate);  // load class (that will be "available later")
		CHHook2(MicroMessengerAppDelegate, application, didFinishLaunchingWithOptions); // register hook
        CHLoadLateClass(CMessageMgr);
        CHHook1(CMessageMgr, onRevokeMsg);
        CHLoadLateClass(FindFriendEntryViewController);
        CHHook2(FindFriendEntryViewController, tableView, heightForRowAtIndexPath);
        CHHook2(FindFriendEntryViewController, tableView, cellForRowAtIndexPath);
        CHLoadLateClass(UITabBarItem);
        CHHook1(UITabBarItem, setBadgeValue);
	}
}
