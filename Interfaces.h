#import <notify.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#include <dlfcn.h>

extern "C" NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);



@protocol SBUIPasscodeLockViewDelegate <NSObject>
@optional
- (void)passcodeLockViewCancelButtonPressed:(id)pressed;
- (void)passcodeLockViewEmergencyCallButtonPressed:(id)pressed;
- (void)passcodeLockViewPasscodeDidChange:(id)passcodeLockViewPasscode;
- (void)passcodeLockViewPasscodeEntered:(id)entered;
- (void)passcodeLockViewPasscodeEnteredViaMesa:(id)mesa;
@end
@interface SBApplication : NSObject
- (id)bundleIdentifier;
- (id)initWithBundleIdentifier:(id)arg1 webClip:(id)arg2 path:(id)arg3 bundle:(id)arg4 infoDictionary:(id)arg5 isSystemApplication:(_Bool)arg6 signerIdentity:(id)arg7 provisioningProfileValidated:(_Bool)arg8 entitlements:(id)arg9;
- (id)displayName;
@end
@interface SBIcon : NSObject
- (void)launchFromLocation:(int)location;
- (id)displayName;
@end
@interface SBApplicationIcon : NSObject
- (void)launchFromLocation:(int)location;
- (id)displayName;
- (id)application;
@end
@interface UIApplication (Asos)
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
-(void)_handleMenuButtonEvent;
- (void)_giveUpOnMenuDoubleTap;
- (void)_menuButtonDown:(id)arg1;
- (void)menuButtonDown:(id)arg1;
- (BOOL)clickedMenuButton;
- (BOOL)handleMenuButtonDownEvent;
- (void)handleHomeButtonTap;
- (void)_giveUpOnMenuDoubleTap;
@end

//@interface SBUIPasscodeLockViewBase : UIView
//@property(nonatomic) _Bool shouldResetForFailedPasscodeAttempt;
//@property(nonatomic) unsigned long long biometricMatchMode;
//@property(nonatomic, getter=_luminosityBoost, setter=_setLuminosityBoost:) double luminosityBoost;
//@property(retain, nonatomic) id backgroundLegibilitySettingsProvider;
////@property(nonatomic, getter=_entryField, setter=_setEntryField:) SBUIPasscodeEntryField *_entryField;
//@property(nonatomic, getter=_entryField, setter=_setEntryField:) id _entryField;
//@property(retain, nonatomic) UIColor *customBackgroundColor;
//@property(nonatomic) double backgroundAlpha;
//@property(nonatomic) _Bool showsStatusField;
//@property(nonatomic) _Bool showsEmergencyCallButton;
//@property(nonatomic) NSString *passcode;
//@property(nonatomic) int style;
//@property(nonatomic) id <SBUIPasscodeLockViewDelegate> delegate;
//- (void)reset;
//- (void)resetForFailedPasscode;
//@end
//@interface SBUIPasscodeLockViewWithKeypad : SBUIPasscodeLockViewBase
//@property(retain, nonatomic) UILabel *statusTitleView;
//-(id)passcode;
//@end
//@interface SBUIPasscodeLockViewSimple4DigitKeypad : SBUIPasscodeLockViewWithKeypad
//@end

@interface _UIBackdropView : UIView
- (id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3;
- (void)setBlurQuality:(id)arg1;
@end
@interface _UIBackdropViewSettings : NSObject
+ (id)settingsForPrivateStyle:(int)arg1;
@end
@interface SpringBoard : NSObject
- (void)_handleMenuButtonEvent;
@end
@interface SBAppSliderController : NSObject
- (void)animateDismissalToDisplayIdentifier:(id)arg1 withCompletion:(id)arg2;
- (void)sliderScroller:(id)arg1 itemTapped:(unsigned long long)arg2;
@end
//@interface SBIconController : NSObject
//+(id)sharedInstance;
//-(void)handleHomeButtonTap;
//@end
@interface SBUIController : NSObject
+ (id)sharedInstance;
- (void)getRidOfAppSwitcher;
@end
@interface CAFilter : NSObject
+(instancetype)filterWithName:(NSString *)name;
@end
//@interface SBDeviceLockController : NSObject
//{
//    int _lockState;
//    double _lastLockDate;
//    _Bool _isPermanentlyBlocked;
//    _Bool _isBlockedForThermalCondition;
//    double _deviceLockUnblockTime;
//    _Bool _okToSendNotifications;
//    NSString *_lastIncorrectPasscodeAttempt;
//}
//
//+ (id)_sharedControllerIfExists;
//+ (id)sharedController;
//+ (id)_sharedControllerCreateIfNecessary:(_Bool)arg1;
//- (id)description;
//- (void)_uncachePasscodeIfNecessary;
//- (void)_cachePassword:(id)arg1;
//- (_Bool)shouldAllowUnlockToApplication:(id)arg1;
//- (void)_removeDeviceLockDisableAssertion:(id)arg1;
//- (void)_addDeviceLockDisableAssertion:(id)arg1;
//- (_Bool)attemptDeviceUnlockWithPassword:(id)arg1 appRequested:(_Bool)arg2;
//- (void)_notifyOfFirstUnlock;
//- (void)_setLockState:(int)arg1;
//- (void)_enablePasscodeLockImmediately:(_Bool)arg1;
//- (void)enablePasscodeLockImmediately;
//- (void)_updateDeviceLockedState;
//- (_Bool)_shouldLockDeviceNow;
//- (_Bool)isPasscodeLockedOrBlocked;
//- (_Bool)isPasscodeLocked;
//- (_Bool)isPasscodeLockedCached;
//- (_Bool)deviceHasPasscodeSet;
//- (void)_setDeviceLockUnblockTime:(double)arg1;
//- (void)_unblockTimerFired;
//- (void)_scheduleUnblockTimer;
//- (void)_clearUnblockTimer;
//- (void)_clearBlockedState;
//- (_Bool)isPermanentlyBlocked:(double *)arg1;
//- (_Bool)isBlocked;
//- (_Bool)_temporarilyBlocked;
//- (void)setBlockedForThermalCondition:(_Bool)arg1;
//- (void)_sendBlockStateChangeNotification;
//- (_Bool)isBlockedForThermalCondition;
//- (id)lastLockDate;
//- (void)dealloc;
//- (id)init;
//
//@end
@interface SwitcherTrayView
+ (id)sharedInstance;
- (void)closeTray;
@end
@interface SwitcherTrayCardView : UIView
@property (nonatomic, retain) id application;
@end