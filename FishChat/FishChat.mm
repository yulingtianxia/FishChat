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

CHDeclareClass(UIApplication)
CHDeclareClass(MicroMessengerAppDelegate)
CHDeclareClass(CMessageMgr)
CHDeclareClass(FindFriendEntryViewController)
CHDeclareClass(MMTabBarController)
CHDeclareClass(MMBadgeView)
CHDeclareClass(WCDeviceStepObject)
CHDeclareClass(NewMainFrameViewController)
CHDeclareClass(UIView)

UIViewController *viewControllerOfResponder(UIResponder *responder)
{
    UIResponder *current = responder;
    while (current && ![current isKindOfClass:UIViewController.class]) {
        current = [current nextResponder];
    }
    return (UIViewController *)current;
}

// 监听 Cycript 8888 端口
CHOptimizedMethod2(self, void, MicroMessengerAppDelegate, application, UIApplication *, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    CHSuper2(MicroMessengerAppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    NSLog(@"## Start Cycript ##");
    CYListenServer(CYCRIPT_PORT);
}

// 阻止撤回消息
CHOptimizedMethod1(self, void, CMessageMgr, onRevokeMsg, id, msg)
{
    NSLog(@"onRevokeMsg: msg Class:%@", NSStringFromClass(object_getClass(msg)));
    return;
}

// 关闭朋友圈入口
CHOptimizedMethod2(self, CGFloat, FindFriendEntryViewController, tableView, UITableView *, tableView, heightForRowAtIndexPath, NSIndexPath *, indexPath)
{
    NSLog(@"## Hide Time Line Entry ##");
    NSIndexPath *timelineIndexPath = [self valueForKeyPath:@"m_WCTimeLineIndexPath"];
    if ([indexPath isEqual: timelineIndexPath] || indexPath.section == 2) {
        return 0;
    }
    return CHSuper2(FindFriendEntryViewController, tableView, tableView, heightForRowAtIndexPath, indexPath);
}

CHOptimizedMethod2(self, UITableViewCell *, FindFriendEntryViewController, tableView, UITableView *, tableView, cellForRowAtIndexPath, NSIndexPath *, indexPath)
{
    NSLog(@"## Hide Time Line Entry ##");
    NSIndexPath *timelineIndexPath = [self valueForKeyPath:@"m_WCTimeLineIndexPath"];
    UITableViewCell *cell = CHSuper2(FindFriendEntryViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([indexPath isEqual: timelineIndexPath] || indexPath.section == 2) {
        cell.hidden = YES;
        for (UIView *subview in cell.subviews) {
            [subview removeFromSuperview];
        }
    }
    return cell;
}

CHOptimizedMethod1(self, void, FindFriendEntryViewController, viewDidAppear, BOOL, animated)
{
    CHSuper1(FindFriendEntryViewController, viewDidAppear, animated);
    [self performSelector:@selector(reloadData)];
}

// 去掉 TabBar 小红点

CHOptimizedMethod2(self, void, MMTabBarController, setTabBarBadgeImage, id, arg1, forIndex, unsigned int, arg2)
{
    if (arg2 != 2 && arg2 != 3) {
        CHSuper2(MMTabBarController, setTabBarBadgeImage, arg1, forIndex, arg2);
    }
}

CHOptimizedMethod2(self, void, MMTabBarController, setTabBarBadgeString, id, arg1, forIndex, unsigned int, arg2)
{
    if (arg2 != 2 && arg2 != 3) {
        CHSuper2(MMTabBarController, setTabBarBadgeString, arg1, forIndex, arg2);
    }
}

CHOptimizedMethod2(self, void, MMTabBarController, setTabBarBadgeValue, id, arg1, forIndex, unsigned int, arg2)
{
    if (arg2 != 2 && arg2 != 3) {
        CHSuper2(MMTabBarController, setTabBarBadgeValue, arg1, forIndex, arg2);
    }
}

// 去掉各种小红点

CHOptimizedMethod1(self, void, MMBadgeView, SetImage, id, arg1)
{
    UIViewController *vc = viewControllerOfResponder((UIResponder *)self);
    if ([NSStringFromClass(vc.class) isEqualToString:@"NewMainFrameViewController"]) {
        return CHSuper1(MMBadgeView, SetImage, arg1);
    }
}

CHOptimizedMethod1(self, void, MMBadgeView, setImage, id, arg1)
{
    UIViewController *vc = viewControllerOfResponder((UIResponder *)self);
    if ([NSStringFromClass(vc.class) isEqualToString:@"NewMainFrameViewController"]) {
        return CHSuper1(MMBadgeView, setImage, arg1);
    }
}

CHOptimizedMethod1(self, void, MMBadgeView, setString, id, arg1)
{
    UIViewController *vc = viewControllerOfResponder((UIResponder *)self);
    if ([NSStringFromClass(vc.class) isEqualToString:@"NewMainFrameViewController"]) {
        return CHSuper1(MMBadgeView, setString, arg1);
    }
}

CHOptimizedMethod1(self, void, MMBadgeView, setValue, unsigned long long, arg1)
{
    UIViewController *vc = viewControllerOfResponder((UIResponder *)self);
    if ([NSStringFromClass(vc.class) isEqualToString:@"NewMainFrameViewController"]) {
        return CHSuper1(MMBadgeView, setValue, arg1);
    }
}

CHOptimizedMethod1(self, void, UIView, didAddSubview, UIView *, subview)
{
    if ([subview isKindOfClass:NSClassFromString(@"MMBadgeView")]) {
        [subview removeFromSuperview];
    }
}

// 微信运动步数

CHOptimizedMethod0(self, unsigned int, WCDeviceStepObject, m7StepCount)
{
    unsigned int count = CHSuper0(WCDeviceStepObject, m7StepCount);
    return count + 10000;
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
        CHHook1(FindFriendEntryViewController, viewDidAppear);
        CHLoadLateClass(MMTabBarController);
        CHHook2(MMTabBarController, setTabBarBadgeImage, forIndex);
        CHHook2(MMTabBarController, setTabBarBadgeString, forIndex);
        CHHook2(MMTabBarController, setTabBarBadgeValue, forIndex);
//        CHLoadLateClass(MMBadgeView);
//        CHHook1(MMBadgeView, setImage);
//        CHHook1(MMBadgeView, SetImage);
//        CHHook1(MMBadgeView, setString);
//        CHHook1(MMBadgeView, setValue);
        CHLoadLateClass(WCDeviceStepObject);
        CHHook0(WCDeviceStepObject, m7StepCount);
        CHLoadLateClass(UIView);
        CHHook1(UIView, didAddSubview);
	}
}
