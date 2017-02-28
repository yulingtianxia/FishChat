//
//  FishConfigurationCenter.h
//  FishChat
//
//  Created by 杨萧玉 on 2017/2/26.
//
//

#import <UIKit/UIKit.h>

@interface FishConfigurationCenter : NSObject

@property (nonatomic, getter = isNightMode) BOOL nightMode;
@property (nonatomic) NSInteger stepCount;
@property (nonatomic, getter=onRevokeMsg) BOOL revokeMsg;

+ (instancetype)sharedInstance;

- (void)handleNightMode:(UISwitch *)sender;
- (void)handleStepCount:(UITextField *)sender;

@end
