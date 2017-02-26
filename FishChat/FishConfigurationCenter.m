//
//  FishConfigurationCenter.m
//  FishChat
//
//  Created by 杨萧玉 on 2017/2/26.
//
//

#import "FishConfigurationCenter.h"

@implementation FishConfigurationCenter

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static FishConfigurationCenter *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [FishConfigurationCenter new];
    });
    return _instance;
}

- (void)handleNightMode:(UISwitch *)sender
{
    self.nightMode = sender.isOn;
}

- (void)handleStepCount:(UITextField *)sender
{
    self.stepCount = sender.text.integerValue;
    [[self viewControllerOfResponder:sender].view setNeedsDisplay];
}

- (UIViewController *)viewControllerOfResponder:(UIResponder *)responder
{
    UIResponder *current = responder;
    while (current && ![current isKindOfClass:UIViewController.class]) {
        current = [current nextResponder];
    }
    return (UIViewController *)current;
}

@end
