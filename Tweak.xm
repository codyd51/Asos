
#import <notify.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/QuartzCore.h>
#include <dlfcn.h>
#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.phillipt.asos.plist"]
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
@interface SBUIPasscodeLockViewBase : UIView
@property(nonatomic) _Bool shouldResetForFailedPasscodeAttempt;
@property(nonatomic) unsigned long long biometricMatchMode;
@property(nonatomic, getter=_luminosityBoost, setter=_setLuminosityBoost:) double luminosityBoost;
@property(retain, nonatomic) id backgroundLegibilitySettingsProvider;
//@property(nonatomic, getter=_entryField, setter=_setEntryField:) SBUIPasscodeEntryField *_entryField;
@property(nonatomic, getter=_entryField, setter=_setEntryField:) id _entryField;
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
@interface SBUIController : NSObject
+ (id)sharedInstance;
- (void)getRidOfAppSwitcher;
@end
@interface CAFilter : NSObject
+(instancetype)filterWithName:(NSString *)name;
@end

//typedef void(^passCompletion)(BOOL);

UITextField* passcodeField;
SBUIPasscodeLockViewSimple4DigitKeypad* passcodeView = [[%c(SBUIPasscodeLockViewSimple4DigitKeypad) alloc] init];
_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForPrivateStyle:3900];
_UIBackdropView *blurView = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];
BOOL shouldLaunch = NO;
NSString* bundleID = @"";
NSString* dispName = @"";
NSMutableDictionary* prefs = [[NSMutableDictionary alloc] init];
NSMutableArray* lockedApps = [[NSMutableArray alloc] init];
UIView* key = [[UIView alloc] init];
id menuButtonDownStamp;
BOOL isFromMulti = NO;
id appSlider;
NSMutableArray* openApps = [[NSMutableArray alloc] init];
NSString* tempString = @"";
NSString* userPass = @"";
BOOL enabled = YES;
BOOL useRealPass = YES;
BOOL enteredCorrectPass;
BOOL isToMulti;
BOOL isUnlocking = YES;
NSString* settingsPass;
NSString* appToOpen;
//CGRect bounds = [[UIScreen mainScreen] bounds];
//UIWindow *aboveWindow = [[UIWindow alloc] initWithFrame:bounds];
UIWindow *aboveWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];

@implementation PassShower
-(void)showPassViewWithBundleID:(NSString*)passedID andDisplayName:(NSString*)passedDisplayName toWindow:(UIView*)window {
	//[[UIApplication sharedApplication] _giveUpOnMenuDoubleTap];
	//[[UIApplication sharedApplication] _handleMenuButtonEvent];
	passcodeView.userInteractionEnabled = YES;
	passcodeView.shouldResetForFailedPasscodeAttempt = YES;
	passcodeView.backgroundColor = [UIColor clearColor];
	passcodeView.backgroundAlpha = 0.9;
	passcodeView.alpha = 0;
	passcodeView.userInteractionEnabled = YES;
	passcodeView.statusTitleView.text = [NSString stringWithFormat:@"Enter Passcode to open %@", passedDisplayName];
	passcodeView.showsEmergencyCallButton = NO;
	passcodeView.tag = 1337;
	[passcodeView reset];

	blurView.alpha = 0;
	[blurView setBlurQuality:@"default"];

	[window addSubview:blurView];
	[window addSubview:passcodeView];

	[UIView animateWithDuration:0.4 animations:^{
		passcodeView.alpha = 1.0;
		blurView.alpha = 1.0;
	}];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	SpringBoard* spring = (SpringBoard*)[UIApplication sharedApplication];
	[spring _handleMenuButtonEvent];
	//[appSlider animateDismissalToDisplayIdentifier:@"com.apple.springboard" withCompletion:nil];
}
@end

PassShower* handler = [[PassShower alloc] init];

%hook SBApplicationIcon
- (void)launchFromLocation:(int)location {
	SBApplication* app = (SBApplication*)[self application];
	NSLog(@"%@", [app bundleIdentifier]);
	bundleID = [app bundleIdentifier];
	dispName = [self displayName];

	if ([lockedApps containsObject:bundleID]) {
		key = [[UIApplication sharedApplication] keyWindow];

		if (!shouldLaunch) {
			[handler showPassViewWithBundleID:bundleID andDisplayName:dispName toWindow:key];
		}
		else {
			%orig;
			shouldLaunch = NO;
			[passcodeView reset];
		}
	}
	else {
		%orig;
		shouldLaunch = NO;
		[passcodeView reset];
	}
}
%end

%hook SBUIPasscodeLockViewWithKeypad

- (void)passcodeEntryFieldTextDidChange:(id)arg1 {
	NSString* passToUse;
	if ([self tag] == 1337) {
		if ([[self passcode] length] == 4) {
			if (useRealPass) passToUse = userPass;
			else if (settingsPass) passToUse = settingsPass;
			else {
				UIAlertView* noPassAlert = [[UIAlertView alloc] initWithTitle:@"Asos" message:@"Please configure your passcode settings in Asos preferences." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[noPassAlert show];
			}
			if ([[self passcode] isEqualToString:passToUse]) {
				enteredCorrectPass = YES;
				//isUnlocking = NO;
				notify_post("com.phillipt.asos.multitaskEscape");
				[UIView animateWithDuration:0.4 animations:^{
					passcodeView.statusTitleView.text = @"✓";
					passcodeView.alpha = 0;
					blurView.alpha = 0;
					//[passcodeView removeFromSuperview];
				}];
				[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];

				//UIAlertView* doneAlert = [[UIAlertView alloc] initWithTitle:@"Testing" message:@"Success!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				//[doneAlert show];

				//shouldLaunch = YES;
			}
			else {
				//To fix the last bubble not dissapearing
				if (!isFromMulti) {
					NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(resetFailedPass) userInfo:nil repeats:NO];
				}
				else {
					UIAlertView* homeAlert = [[UIAlertView alloc] initWithTitle:@"Testing" message:@"Should exit to homescreen now." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[homeAlert show];
					SpringBoard* spring = (SpringBoard*)[UIApplication sharedApplication];
					[spring _handleMenuButtonEvent];
					[self resetForFailedPasscode];
					isFromMulti = NO;
				}
				//[self resetForFailedPasscode];
			}
		}
	}
	%orig;
}

- (void)passcodeLockNumberPadCancelButtonHit:(id)arg1 {
	if ([self tag] == 1337) {
		[UIView animateWithDuration:0.3 animations:^{
			passcodeView.alpha = 0;
			blurView.alpha = 0;
			//[passcodeView removeFromSuperview];
		}];
	}
	%orig;
}

- (void)passcodeLockNumberPadBackspaceButtonHit:(id)arg1 {
	//To fix the last number still being filled
	if ([self tag] == 1337) {
		if ([[self passcode] length] == 0) [self reset];
	}
	%orig;
}

%new
-(void)resetFailedPass {
	[UIView animateWithDuration:0.5 animations:^{
		passcodeView.statusTitleView.text = @"✗";
	}];
	[UIView animateWithDuration:0.5 animations:^{
		passcodeView.statusTitleView.text = [NSString stringWithFormat:@"Enter Passcode to open %@", dispName];
	}];
	
	[self resetForFailedPasscode];
}

%end

void loadPreferences() {
	prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];
/*
	if ([prefs objectForKey:@"enabled"] != nil) enabled = [[prefs objectForKey:@"enabled"] boolValue];
	if ([prefs objectForKey:@"swipeState"] != nil) swipeState = [[prefs objectForKey:@"swipeState"] intValue];
	if ([prefs objectForKey:@"bypass"] != nil) bypass = [[prefs objectForKey:@"bypass"] boolValue];
	if ([prefs objectForKey:@"disableNorm"] != nil) disableNorm = [[prefs objectForKey:@"disableNorm"] boolValue];
*/
	[lockedApps removeAllObjects];
	for (id key in [prefs allKeys]) {
		if ([[prefs objectForKey:key] boolValue]) {
			NSString* fullString = (NSString*)key;
			if ([fullString rangeOfString:@"lock-"].location != NSNotFound) {
				NSString* trimmedString = [fullString substringFromIndex:5];
				[lockedApps addObject:trimmedString];
			}
		}
	}
	if ([prefs objectForKey:@"enabled"] != nil) enabled = [[prefs objectForKey:@"enabled"] boolValue];
	if ([prefs objectForKey:@"useRealPass"] != nil) useRealPass = [[prefs objectForKey:@"useRealPass"] boolValue];
	settingsPass = [prefs objectForKey:@"passcode"];
}

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	notify_post("com.phillipt.asos/settingschanged");
	loadPreferences();
}

-(void)menuButtonDown:(id)arg1 {
	%log;
	%orig;
}

-(void)_menuButtonDown:(id)arg1 {
	//%log;
	menuButtonDownStamp = arg1;
	%orig;
}

%end

id scroller;
int indexTapped;

%hook SBAppSliderController
- (id)init {
	appSlider = self;
	return %orig;
}
-(void)sliderScroller:(id)scroller1 itemTapped:(unsigned)tapped {
	%log;
	scroller = scroller1;
	indexTapped = tapped;
	if (isUnlocking) {
		isToMulti = YES;
		key = [[UIApplication sharedApplication] keyWindow];
		appToOpen = [openApps objectAtIndex:tapped];
		NSLog(@"itemTapped: %@", appToOpen);
		if ([lockedApps containsObject:appToOpen]) {
			NSString* appDisplayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(appToOpen);
			//SBApplication* appWithDisplay = [[SBApplication alloc] initWithBundleIdentifier:appToOpen];
			[handler showPassViewWithBundleID:appToOpen andDisplayName:appDisplayName toWindow:key];
			/*
			[appSlider animateDismissalToDisplayIdentifier:@"com.apple.springboard" withCompletion:^{
			[[%c(SBUIController) sharedInstance] getRidOfAppSwitcher];
				}];
			UIAlertView* lockedAlert = [[UIAlertView alloc] initWithTitle:@"Asos" message:@"This app is locked. Please open it from the homescreen to 	input your passcode." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[lockedAlert show];
			return;
			*/
		}
		else %orig;
	}
	else %orig;
}

- (id)_beginAppListAccess { 
	openApps = %orig;
	return openApps;
}

%end

%hook SBAppSliderSnapshotView

+(id)appSliderSnapshotViewForApplication:(SBApplication*)application orientation:(int)orientation loadAsync:(BOOL)async withQueue:(id)queue statusBarCache:(id)cache {
	if([lockedApps containsObject:[application bundleIdentifier]]){
		//UIImage* padlockImage = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/Application Support/Asos/" error:nil] objectAtIndex:0];
		UIImageView *snapshot = (UIImageView *) %orig();
		CAFilter *filter = [CAFilter filterWithName:@"gaussianBlur"];
		[filter setValue:@10 forKey:@"inputRadius"];
		snapshot.layer.filters = [NSArray arrayWithObject:filter];
		[snapshot addSubview:padlockImage];
		return snapshot;
	}
	return %orig;
}

%end

%hook SBLockScreenManager

- (BOOL)attemptUnlockWithPasscode:(id)arg1 {
	BOOL didSucceed = %orig;
	if (didSucceed) userPass = (NSString*)arg1;
	return didSucceed;
}

%end

void dismissToApp() {
	if (isToMulti) {
		isUnlocking = NO;
		[appSlider sliderScroller:scroller itemTapped:indexTapped];
		isUnlocking = YES;
		[appSlider animateDismissalToDisplayIdentifier:appToOpen withCompletion:nil];
		isToMulti = NO;
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)loadPreferences,
									CFSTR("com.phillipt.asos/settingschanged"),
									NULL,
									CFNotificationSuspensionBehaviorDeliverImmediately);
	
	loadPreferences();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)dismissToApp,
									CFSTR("com.phillipt.asos.multitaskEscape"),
									NULL,
									CFNotificationSuspensionBehaviorDeliverImmediately);
	
	dismissToApp();
}
