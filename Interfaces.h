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
//@interface SBIcon : NSObject
//- (void)launchFromLocation:(int)location;
//- (id)displayName;
//@end
//@interface SBApplicationIcon : NSObject
//- (void)launchFromLocation:(int)location;
//- (id)displayName;
//- (id)application;
//@end
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
/*
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
*/
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
@interface SBDeviceLockController : NSObject
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
+ (id)_sharedControllerIfExists;
+ (id)sharedController;
+ (id)_sharedControllerCreateIfNecessary:(_Bool)arg1;
- (id)description;
- (void)_uncachePasscodeIfNecessary;
- (void)_cachePassword:(id)arg1;
//- (_Bool)shouldAllowUnlockToApplication:(id)arg1;
//- (void)_removeDeviceLockDisableAssertion:(id)arg1;
//- (void)_addDeviceLockDisableAssertion:(id)arg1;
- (_Bool)attemptDeviceUnlockWithPassword:(id)arg1 appRequested:(_Bool)arg2;
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

@end
@interface SwitcherTrayView
+ (id)sharedInstance;
- (void)closeTray;
@end
@interface SBIconView : UIView
@end
@interface SBIconViewMap : NSObject
+(id)homescreenMap;
-(SBIconView*)iconViewForIcon:(id)arg1;
@end
@interface SwitcherTrayCardView : UIView
@property (nonatomic, retain) id application;
@end

#import <notify.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/QuartzCore.h>
#include <dlfcn.h>
extern "C" NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);

@interface SBIcon : NSObject
- (void)launchFromLocation:(int)location;
- (id)displayName;
@end
@interface SBApplicationIcon : NSObject
- (void)launchFromLocation:(int)location;
- (id)displayName;
- (id)application;
-(id)applicationBundleID;
@end
@interface SBUIPasscodeLockViewBase : UIView
@property(nonatomic) _Bool shouldResetForFailedPasscodeAttempt;
@property(nonatomic) unsigned long long biometricMatchMode;
@property(nonatomic) double luminosityBoost;
@property(retain, nonatomic) id backgroundLegibilitySettingsProvider;
//@property(nonatomic, getter=_entryField, setter=_setEntryField:) SBUIPasscodeEntryField *_entryField;
@property(nonatomic) id _entryField;
@property(retain, nonatomic) UIColor *customBackgroundColor;
@property(nonatomic) double backgroundAlpha;
@property(nonatomic) _Bool showsStatusField;
@property(nonatomic) _Bool showsEmergencyCallButton;
@property(nonatomic) NSString *passcode;
@property(nonatomic) int style;
@property(nonatomic) id <SBUIPasscodeLockViewDelegate> delegate;
- (void)reset;
- (void)resetForFailedPasscode;
@end
@interface SBUIPasscodeLockViewWithKeypad : SBUIPasscodeLockViewBase
@property(retain, nonatomic) UILabel *statusTitleView;
-(id)passcode;
@end
@interface SBUIPasscodeLockViewSimple4DigitKeypad : SBUIPasscodeLockViewWithKeypad
-(void)passcodeLockNumberPadCancelButtonHit:(id)arg1;
-(void)passcodeLockNumberPadBackspaceButtonHit:(id)arg1;
@end
@interface _UIBackdropView : UIView
- (id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3;
- (void)setBlurQuality:(id)arg1;
@end
@interface _UIBackdropViewSettings : NSObject
+ (id)settingsForPrivateStyle:(int)arg1;
@end
@interface PassShower : NSObject <UIAlertViewDelegate>
-(void)showPassViewWithBundleID:(NSString*)passedID andDisplayName:(NSString*)passedDisplayName toWindow:(UIView*)window;
@end
@interface SpringBoard : NSObject
- (void)_handleMenuButtonEvent;
@end
@interface SBAppSliderController : NSObject
- (void)animateDismissalToDisplayIdentifier:(id)arg1 withCompletion:(id)arg2;
- (void)sliderScroller:(id)arg1 itemTapped:(unsigned long long)arg2;
@end
@interface SBIconController : NSObject
+(id)sharedInstance;
-(void)handleHomeButtonTap;
@end

@interface SBAppSwitcherController : UIViewController {
}
@property (copy) Class superclass; 
@property (copy,copy) NSString* description; 
@property (copy,copy) NSString* debugDescription; 
+(void)setPerformSochiMigrationTasksWhenLoaded:(_Bool)arg1;
+(_Bool)shouldProvideSnapshotIfPossible;
+(_Bool)shouldProvideHomeSnapshotIfPossible;
+(_Bool)_shouldUseSerialSnapshotQueue;
+(double)pageScale;
-(void)handleReachabilityModeDeactivated;
-(id)_peopleViewController;
-(void)handleVolumeIncrease;
-(void)handleVolumeDecrease;
-(_Bool)allowShowHide;
-(void)animatePresentationFromDisplayLayout:(id)arg1 withViews:(id)arg2 withCompletion:(id)arg3;
-(void)switcherWasPresented:(_Bool)arg1;
-(_Bool)workspaceShouldAbortLaunchingAppDueToSwitcher:(id)arg1 url:(id)arg2 actions:(id)arg3;
-(void)switcherWillBeDismissed:(_Bool)arg1;
-(void)switcherWasDismissed:(_Bool)arg1;
-(void)animateDismissalToDisplayLayout:(id)arg1 withCompletion:(id)arg2;
-(void)handleRevealNotificationCenterGesture:(id)arg1;
-(_Bool)_shouldRespondToReachability;
-(void)_performReachabilityTransactionForActivate:(_Bool)arg1 immediately:(_Bool)arg2;
-(void)_switcherServiceRemoved:(id)arg1;
-(void)_appActivationStateDidChange:(id)arg1;
-(void)_switcherRemoteAlertRemoved:(id)arg1;
-(void)_switcherRemoteAlertAdded:(id)arg1;
-(void)_continuityAppSuggestionChanged:(id)arg1;
-(void)_warmAppInfoForAppsInList;
-(void)_finishDeferredSochiMigrationTasks;
-(void)handleCancelReachabilityGesture:(id)arg1;
-(double)_switcherThumbnailVerticalPositionOffset;
-(CGRect)_nominalPageViewFrame;
-(void)setStartingDisplayLayout:(id)arg1;
-(void)setStartingViews:(id)arg1;
-(void)_cacheAppList;
-(void)_updatePageViewScale:(double)arg1 xTranslation:(double)arg2;
-(void)_temporarilyHostAppForQuitting:(id)arg1;
-(void)_layoutInOrientation:(long long)arg1;
-(void)_updateForAnimationFrame:(double)arg1 withAnchor:(id)arg2;
-(void)_bringIconViewToFront;
-(id)_transitionAnimationFactory;
-(_Bool)_inMode:(int)arg1;
-(void)_updateSnapshots;
-(void)_peopleWillAnimateOpacity;
-(void)_peopleDidAnimateOpacity;
-(id)_animationFactoryForIconAlphaTransition;
-(void)_accessAppListState:(id)arg1;
-(void)_setInteractionEnabled:(_Bool)arg1;
-(void)_unsimplifyStatusBarsAfterMotion;
-(void)_disableContextHostingForApp:(id)arg1;
-(void)_destroyAppListCache;
-(void)_askDelegateToDismissToDisplayLayout:(id)arg1 displayIDsToURLs:(id)arg2 displayIDsToActions:(id)arg3;
-(id)_generateCellViewForDisplayLayout:(id)arg1;
-(double)_scaleForFullscreenPageView;
-(void)_quitAppWithDisplayItem:(id)arg1;
-(void)_rebuildAppListCache;
-(id)pageForDisplayLayout:(id)arg1;
-(void)addContentViewForRemoteAlert:(id)arg1 toAlertViewCell:(id)arg2 animated:(_Bool)arg3;
-(id)_viewForService:(id)arg1;
-(id)_viewForRemoteAlert:(id)arg1 placeholder:(_Bool)arg2;
-(id)_viewForContinuityApp:(id)arg1;
-(id)_snapshotViewForDisplayItem:(id)arg1;
-(_Bool)_isBestAppSuggestionEligibleForSwitcher:(id)arg1;
-(id)_flattenedArrayOfDisplayItemsFromDisplayLayouts:(id)arg1;
-(id)_displayLayoutsFromDisplayLayouts:(id)arg1 byRemovingDisplayItems:(id)arg2;
-(void)_insertDisplayLayout:(id)arg1 atIndex:(unsigned long long)arg2 completion:(id)arg3;
-(void)_removeDisplayLayout:(id)arg1 completion:(id)arg2;
-(void)_updateSnapshotsForce:(_Bool)arg1;
-(unsigned long long)_totalLayoutsForWhichToKeepAroundSnapshots;
-(_Bool)_isSnapshotDisplayIdentifier:(id)arg1;
-(void)launchAppWithIdentifier:(id)arg1 url:(id)arg2 actions:(id)arg3;
-(void)_simplifyStatusBarsForMotion;
-(void)_insertRemoteAlertPlaceholder:(id)arg1 atIndex:(unsigned long long)arg2 completion:(id)arg3;
-(void)_removeRemoteAlertPlaceholder:(id)arg1 completion:(id)arg2;
-(void)_insertApp:(id)arg1 atIndex:(unsigned long long)arg2 completion:(id)arg3;
-(void)_animateReachabilityActivatedWithHandler:(id)arg1;
-(void)_animateReachabilityDeactivatedWithHandler:(id)arg1;
-(void)switcherIconScroller:(id)arg1 contentOffsetChanged:(double)arg2;
-(void)switcherIconScroller:(id)arg1 activate:(id)arg2;
-(_Bool)switcherIconScroller:(id)arg1 shouldHideIconForDisplayLayout:(id)arg2;
-(void)switcherIconScrollerBeganPanning:(id)arg1;
-(unsigned long long)switcherIconScroller:(id)arg1 settledIndexForNormalizedOffset:(int)arg2 andXVelocity:(double)arg3;
-(void)switcherIconScrollerDidEndScrolling:(id)arg1;
-(id)switcherScroller:(id)arg1 viewForDisplayLayout:(id)arg2;
-(_Bool)switcherScroller:(id)arg1 isDisplayItemRemovable:(id)arg2;
-(_Bool)switcherScrollerIsRelayoutBlocked:(id)arg1;
-(CGSize)switcherScrollerItemSize:(id)arg1 forOrientation:(long long)arg2;
-(double)switcherScrollerDistanceBetweenItemCenters:(id)arg1 forOrientation:(long long)arg2;
-(void)switcherScroller:(id)arg1 contentOffsetChanged:(double)arg2;
-(void)switcherScroller:(id)arg1 itemTapped:(int)arg2;
-(void)switcherScrollerBeganPanning:(id)arg1;
-(void)switcherScroller:(id)arg1 displayItemWantsToBeRemoved:(id)arg2;
-(_Bool)switcherScroller:(id)arg1 displayItemWantsToBeKeptInViewHierarchy:(id)arg2;
-(void)switcherScrollerDidEndScrolling:(id)arg1;
-(void)switcherScrollerBeganMoving:(id)arg1;
-(void)switcherScroller:(id)arg1 updatedPeakPageOffset:(double)arg2;
-(double)reachabilityOffsetForSwitcherScroller:(id)arg1;
-(void)appSwitcherContainer:(id)arg1 movedToWindow:(id)arg2;
-(void)peopleController:(id)arg1 wantsToContact:(id)arg2;
-(double)_frameScaleValueForAnimation;
-(void)_updatePageViewScale:(double)arg1;
-(void)_insertMultipleAppDisplayLayout:(id)arg1 atIndex:(unsigned long long)arg2 completion:(id)arg3;
-(void)cleanupRemoteAlertServices;
-(void)dealloc;
-(void)setDelegate:(id)arg1;
-(id)init;
-(_Bool)gestureRecognizerShouldBegin:(id)arg1;
-(_Bool)prefersStatusBarHidden;
-(long long)_windowInterfaceOrientation;
-(_Bool)shouldAutorotate;
-(unsigned long long)supportedInterfaceOrientations;
-(_Bool)wantsFullScreenLayout;
-(void)loadView;
-(_Bool)shouldAutomaticallyForwardRotationMethods;
-(void)willRotateToInterfaceOrientation:(long long)arg1 duration:(double)arg2;
-(void)willAnimateRotationToInterfaceOrientation:(long long)arg1 duration:(double)arg2;
-(void)didRotateFromInterfaceOrientation:(long long)arg1;
-(void)_getRotationContentSettings:(id)arg1;
-(void)_layout;
-(void)settings:(id)arg1 changedValueForKey:(id)arg2;
-(void)setLegibilitySettings:(id)arg1;
-(_Bool)isScrolling;
-(id)pageController;
-(void)handleReachabilityModeActivated;
-(void)forceDismissAnimated:(_Bool)arg1;
@end

@interface SBDisplayItem : NSObject {
	NSString* _uniqueStringRepresentation; 
	NSString* _type; 
	NSString* _displayIdentifier; 
}
@property (nonatomic,copy) NSString* type; 				//@synthesize type=_type - In the implementation block
@property (nonatomic,copy) NSString* displayIdentifier; 				//@synthesize displayIdentifier=_displayIdentifier - In the implementation block
+(id)displayItemWithType:(NSString*)arg1 displayIdentifier:(id)arg2;
-(id)initWithType:(NSString*)arg1 displayIdentifier:(id)arg2;
-(id)_calculateUniqueStringRepresentation;
-(id)plistRepresentation;
-(id)uniqueStringRepresentation;
-(id)initWithPlistRepresentation:(id)arg1;
-(void)dealloc;
-(_Bool)isEqual:(id)arg1;
-(unsigned long long)hash;
-(id)description;
@end

@interface SBDisplayLayout : NSObject {
	long long _layoutSize; 
	NSMutableArray* _displayItems; 
	NSString* _uniqueStringRepresentation; 
}
@property (nonatomic) long long layoutSize; 				//@synthesize layoutSize=_layoutSize - In the implementation block
@property (nonatomic) NSArray* displayItems; 				//@synthesize displayItems=_displayItems - In the implementation block
+(id)displayLayoutWithLayoutSize:(long long)arg1 displayItems:(id)arg2;
+(id)homeScreenDisplayLayout;
+(id)fullScreenDisplayLayoutForApplication:(id)arg1;
+(id)displayLayoutWithPlistRepresentation:(id)arg1;
-(id)_calculateUniqueStringRepresentation;
-(id)plistRepresentation;
-(id)uniqueStringRepresentation;
-(id)displayLayoutByRemovingDisplayItems:(id)arg1;
-(id)displayLayoutByRemovingDisplayItem:(id)arg1;
-(id)initWithLayoutSize:(long long)arg1 displayItems:(id)arg2;
-(id)displayLayoutByAddingDisplayItem:(id)arg1 side:(long long)arg2 withLayout:(long long)arg3;
-(id)displayLayoutByReplacingDisplayItemOnSide:(long long)arg1 withDisplayItem:(id)arg2;
-(id)displayLayoutBySettingSize:(long long)arg1;
-(void)dealloc;
-(_Bool)isEqual:(id)arg1;
-(unsigned long long)hash;
-(id)description;
@end