//
//	Asos
//
//	(c) 2014 Phillip Tennen.
//
//
#import "BTTouchIDController.h"
#import <objc/runtime.h>
#import <AudioToolbox/AudioServices.h>
#import "Interfaces.h"

#define DEBUG_PREFIX @" [Asos]"
#import "DebugLog.h"

@interface NSObject (AssociatedObject)
@property (nonatomic, strong) id associatedObject;
@end

@implementation NSObject (AssociatedObject)
@dynamic associatedObject;
- (void)setAssociatedObject:(id)object {
	objc_setAssociatedObject(self, @selector(associatedObject), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id)associatedObject {
	return objc_getAssociatedObject(self, @selector(associatedObject));
}
@end



// Globals

#define kSettingsPath	[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.phillipt.asos.plist"]
#define kUIBackdropViewSettingsDark				1
#define kUIBackdropViewSettingsColorSample		2000
#define kUIBackdropViewSettingsPasscodePaddle	3900
#define kUIBackdropViewSettingsUltraColored		2080
#define kUIBackdropViewSettingsDarkWithZoom		2031

@class AsosPassShower;
static AsosPassShower *handler;

static NSMutableDictionary* prefs;
static NSMutableArray* lockedApps;
static NSMutableArray* timeLockedApps;
static NSMutableArray* oncePerRespring;
static NSMutableArray* openApps;

static id appSlider;
static id menuButtonDownStamp;
static id scroller;

static NSString* appToOpen;
static NSString* bundleID;
static NSString *currentlyOpening;
static NSString* dispName ;
static NSString* settingsPass;
static NSString* timeInterval;
static NSString* userPass;

static BOOL isFromMulti;
static BOOL isToMulti;
static BOOL isUnlocking;
static BOOL shouldLaunch;
static int indexTapped;

static BOOL enabled;
static BOOL useRealPass;
static BOOL atTime;
static BOOL onceRespring;

// UNDROUPED

// Interfaces ------------------------------------------------------------------

@interface AsosPasscodeView : SBUIPasscodeLockViewSimple4DigitKeypad
-(void)validPassEntered;
@end

@interface AsosPassShower : NSObject <UIAlertViewDelegate>
@property (nonatomic, strong) AsosPasscodeView *passcodeView;
@property (nonatomic, strong) _UIBackdropView *blurView;
- (void)showPasscodeViewWithBundleID:(NSString *)passedID andDisplayName:(NSString *)passedDisplayName;
@end

@interface SBApplicationIcon ()
- (void)shade;
@end

// Helpers ---------------------------------------------------------------------

void loadPreferences() {
	DebugLogC(@"Tweak::loadPreferences()");
	
	[lockedApps removeAllObjects];
	
	prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath] ?: [NSMutableDictionary dictionary];
	DebugLogC(@"read prefs from disk: %@", prefs);
	
	if (prefs[@"enabled"] && ![prefs[@"enabled"] boolValue]) {
		enabled = NO;
	} else {
		enabled = YES;
	}
	DebugLogC(@"setting for enabled:%d", enabled);
	
	
	if ([prefs objectForKey:@"useRealPass"]) {
		useRealPass = [[prefs objectForKey:@"useRealPass"] boolValue];
	} else {
		useRealPass = YES;
	}
	DebugLogC(@"setting for useRealPass:%d", useRealPass);
	
	
	if ([prefs objectForKey:@"onceRespring"]) {
		onceRespring = [[prefs objectForKey:@"onceRespring"] boolValue];
	} else {
		onceRespring = YES;
	}
	DebugLogC(@"setting for onceRespring:%d", onceRespring);
	
	
	if ([prefs objectForKey:@"atTime"]) {
		atTime = [[prefs objectForKey:@"atTime"] boolValue];
	} else {
		atTime = NO;
	}
	DebugLogC(@"setting for atTime:%d", atTime);
	
	
	if ([prefs objectForKey:@"timeInterval"]) {
		int timeToLock = [[prefs objectForKey:@"timeInterval"] intValue] * 60;
		timeInterval = [NSString stringWithFormat:@"%i", timeToLock];
	}
	DebugLogC(@"setting for timeInterval:%@", timeInterval);
	
	
	if ([prefs objectForKey:@"passcode"]) {
		settingsPass = [prefs objectForKey:@"passcode"];
		DebugLogC(@"setting for settingsPass:%@", settingsPass);
	}
	
	
	// populate lockedApps array
	for (NSString *key in [prefs allKeys]) {
		if ([[prefs objectForKey:key] boolValue]) {
			if ([key rangeOfString:@"lock-"].location != NSNotFound) {
				NSString *trimmedString = [key substringFromIndex:5];
				[lockedApps addObject:trimmedString];
			}
		}
	}
}

void dismissToApp() {
	DebugLogC(@"Tweak::dissmissToApp()");
	
	if (isToMulti) {
		isUnlocking = NO;
		[appSlider sliderScroller:scroller itemTapped:indexTapped];
		isUnlocking = YES;
		[appSlider animateDismissalToDisplayIdentifier:appToOpen withCompletion:nil];
		isToMulti = NO;
	}
}



// Classes ----------------------------------------------------------------------


// PasscodeView Class
@implementation AsosPasscodeView
- (instancetype)init {
	self = [super init];
	if (self) {
		self.showsEmergencyCallButton = NO;
		self.shouldResetForFailedPasscodeAttempt = YES;
		self.userInteractionEnabled = YES;
		self.backgroundColor = UIColor.clearColor;
		self.backgroundAlpha = 0.4;
		self.alpha = 0;
	}
	DebugLog(@"New PassCodeView created: %@", self);
	return self;
}
- (void)passcodeEntryFieldTextDidChange:(id)arg1 {
	DebugLog0;
	
	// check the passcode entered after the 4th key press ...
	
	if ([[self passcode] length] == 4) {
		DebugLog(@"Checking passcode...");
		BOOL enteredCorrectPass = NO;
		
		if (useRealPass) {
			// test real pass
			if ([[%c(SBDeviceLockController) sharedController] attemptDeviceUnlockWithPassword:[self passcode] appRequested:nil]) {
				enteredCorrectPass = YES;
			}
		} else if (settingsPass) {
			// test custom passcode
			if ([[self passcode] isEqualToString:settingsPass]) {
				enteredCorrectPass = YES;
			}
		} else {
			// no passcode set for Asos, show alert
			UIAlertView* noPassAlert = [[UIAlertView alloc] initWithTitle:@"Asos" message:@"Please configure your passcode settings in Asos preferences." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[noPassAlert show];
		}
		
		if (enteredCorrectPass) {
			//segmented into seperate method so we can use it with Touch ID monitering
			[self validPassEntered];
		} 
		else {
			DebugLog(@"...passcode was INVALID.");
			// To fix the last bubble not dissapearing
			if (!isFromMulti) {
				[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(resetFailedPass) userInfo:nil repeats:NO];
			} 
			else {
				UIAlertView* homeAlert = [[UIAlertView alloc] initWithTitle:@"Testing" message:@"Should exit to homescreen now." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[homeAlert show];
				
				SpringBoard* spring = (SpringBoard*)[UIApplication sharedApplication];
				[spring _handleMenuButtonEvent];
				
				[self resetForFailedPasscode];
				isFromMulti = NO;
			}
		}
	}
//	[super passcodeEntryFieldTextDidChange:arg1];
}
- (void)passcodeLockNumberPadCancelButtonHit:(id)arg1 {
	DebugLog0;
	[super passcodeLockNumberPadCancelButtonHit:arg1];
	
	[UIView animateWithDuration:0.3 animations:^{
		handler.passcodeView.alpha = 0;
		handler.blurView.alpha = 0;
	}];

	[[BTTouchIDController sharedInstance] stopMonitoring];
}
- (void)passcodeLockNumberPadBackspaceButtonHit:(id)arg1 {
	DebugLog0;
	[super passcodeLockNumberPadBackspaceButtonHit:arg1];
	
	//To fix the last number still being filled
	if (self.passcode.length == 0) {
		[self reset];
	}
}
- (void)resetFailedPass {
	DebugLog0;
//	[super resetFailedPass];
	
	[UIView animateWithDuration:0.5 animations:^{
		handler.passcodeView.statusTitleView.text = @"✗";
	} completion:^(BOOL finished){
		[UIView animateWithDuration:0.5 animations:^{
			//TODO: Only if Touch ID is allowed
			handler.passcodeView.statusTitleView.text = [NSString stringWithFormat:@"Try again"];
		}];
	}];
	
	[self resetForFailedPasscode];
}
-(void)validPassEntered {
	DebugLog(@"...passcode was VALID.");

	if (onceRespring) {
		[lockedApps removeObject:currentlyOpening];
		[oncePerRespring addObject:currentlyOpening];
	}
	if (atTime) {
		[timeLockedApps addObject:currentlyOpening];
		[lockedApps removeObject:currentlyOpening];
		NSTimer* lockRemover = [NSTimer scheduledTimerWithTimeInterval:[timeInterval intValue] target:handler selector:@selector(removeLocked) userInfo:nil repeats:NO];
		[lockRemover setAssociatedObject:currentlyOpening];
	}
			
	// close the switcher
	notify_post("com.phillipt.asos.multitaskEscape");
	
	// dismiss the passcode view
	[UIView animateWithDuration:0.4 animations:^{
		handler.passcodeView.statusTitleView.text = @"✓";
		handler.passcodeView.alpha = 0;
		handler.blurView.alpha = 0;
		//[passcodeView removeFromSuperview];
	}];
			
	// continue launching the app
	[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];

	//stop looking for fingerprint
	[[BTTouchIDController sharedInstance] stopMonitoring];
}

@end


// PassShower Class
@implementation AsosPassShower
- (instancetype)init {
	DebugLog0;
	
	self = [super init];
	if (self) {
		// make blur view ...
		
		_blurView = [[_UIBackdropView alloc] initWithFrame:CGRectZero
								   autosizesToFitSuperview:YES settings:[_UIBackdropViewSettings settingsForPrivateStyle:3900]];
		[_blurView setBlurQuality:@"default"];
		_blurView.alpha = 0;
		DebugLog(@"self.blurView = %@", _blurView);
		
		
		// make passcode view ...
		_passcodeView = [[AsosPasscodeView alloc] init];
		_passcodeView.statusTitleView.text = [NSString stringWithFormat:@"Touch ID or enter passcode to open blah"];
		DebugLog(@"self.passcodeView = %@", _passcodeView);
		
		
		// listen for notifs from preferences
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)loadPreferences,
										CFSTR("com.phillipt.asos/settingschanged"),
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately);
	}
	return self;
}
- (void)showPasscodeViewWithBundleID:(NSString *)passedID andDisplayName:(NSString *)passedDisplayName {
	DebugLog(@"showPassView for: %@ [%@]", passedDisplayName, passedID);
	
	currentlyOpening = passedID;
	[self.passcodeView reset];

	self.blurView.alpha = 0;
	self.passcodeView.alpha = 0;
	
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	[window addSubview:self.blurView];
	[window addSubview:self.passcodeView];
	
	[UIView animateWithDuration:0.4 animations:^{
		//TODO: Only if Touch ID is allowed
		self.passcodeView.statusTitleView.text = [NSString stringWithFormat:@"Touch ID or enter passcode to open %@", passedDisplayName];
		self.passcodeView.alpha = 1.0;
		self.blurView.alpha = 1.0;
	}];

	BTTouchIDController* sharedBT = [BTTouchIDController sharedInstance];
	[sharedBT startMonitoring];
	sharedBT.idToOpen = passedID;

}
- (void)removePasscodeView {
	DebugLog0;
	
	[UIView animateWithDuration:0.4 animations:^{
		self.passcodeView.alpha = 0;
		self.blurView.alpha = 0;
	}];
	
	[self.passcodeView removeFromSuperview];
	[self.blurView removeFromSuperview];

	[[BTTouchIDController sharedInstance] stopMonitoring];
}
- (void)removeLocked {
	DebugLog0;
	id removeObject = [timeLockedApps objectAtIndex:0];
	[lockedApps addObject:removeObject];
	[timeLockedApps removeObject:removeObject];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	DebugLog(@"clicked button: %d", (int)buttonIndex);
	
	if (buttonIndex == alertView.cancelButtonIndex) {
		// user bailed
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
		[self removePasscodeView];
	} else {
		DebugLog(@"Checking passcode...");
		
		UITextField *loginField = [alertView textFieldAtIndex:0];
		NSString *code = loginField.text;
		BOOL codeIsCorrect = NO;
		
		if ([[%c(SBDeviceLockController) sharedController] attemptDeviceUnlockWithPassword:code appRequested:nil]) {
			codeIsCorrect = YES;
		}
		
		if (codeIsCorrect) {
			[alertView dismissWithClickedButtonIndex:0 animated:YES];
			alertView = nil;
			[self removePasscodeView];
		} else {
			// wrong code, much vibration
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		}
	}
}
@end

// H00KS -----------------------------------------------------------------------


%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
	DebugLog0;
	%orig;
	
	loadPreferences();
}
- (void)_menuButtonDown:(id)arg1 {
	DebugLog0;
	menuButtonDownStamp = arg1;
	%orig;
}
%end



%hook SBApplicationIcon
- (id)initWithApplication:(id)arg1 {
	self = %orig;
	return self;
}
- (void)launchFromLocation:(int)location {
	DebugLog0;
	
	SBApplication* app = (SBApplication *)[self application];
	bundleID = [app bundleIdentifier];
	DebugLog(@"app id: %@", bundleID);
	
	currentlyOpening = bundleID;
	dispName = [self displayName];
	
	if ([lockedApps containsObject:bundleID] && ![oncePerRespring containsObject:bundleID]) {
		if (!shouldLaunch) {
			DebugLog(@"showing pass view...");
			[handler showPasscodeViewWithBundleID:bundleID andDisplayName:dispName];
		}
		else {
			%orig;
			shouldLaunch = NO;
			[handler.passcodeView reset];
		}
	}
	else {
		%orig;
		shouldLaunch = NO;
		[handler.passcodeView reset];
	}
}

- (id)generateIconImage:(int)arg1 {
	DebugLog0;
	
	id image = %orig;
	
	//This works really, really bad. Commenting out for now
	/*
	if (lockedApps && [lockedApps containsObject:[self applicationBundleID]]) {
		[self shade];
	} else {
		DebugLog(@"no locked apps.");
	}
	*/

	return image;
}

%new
- (void)shade {
	DebugLog(@"shade()");
	
	SBIconView *iconView = [[%c(SBIconViewMap) homescreenMap] iconViewForIcon:self];
	DebugLog(@"> my iconView is %@", iconView);
	
	//int blurStyle = kUIBackdropViewSettingsPasscodePaddle;
	int blurStyle = kUIBackdropViewSettingsDark;
	
	_UIBackdropView *shade = [[_UIBackdropView alloc] initWithFrame:CGRectZero
											autosizesToFitSuperview:YES
														   settings:[_UIBackdropViewSettings settingsForPrivateStyle:blurStyle]];
	[shade setBlurQuality:@"default"];
	
	CGRect frame = iconView.frame;
	shade.frame = frame;

	shade.clipsToBounds = YES;
	
	DebugLog(@"> created shade: %@", shade);
	[iconView insertSubview:shade atIndex:0];
}
%end


// BEGIN IOS 7 COMPATIBLITY ------------------------------------>>>

%hook SBAppSliderController
- (id)init {
	DebugLog0;
	appSlider = %orig;
	return appSlider;
}
- (void)sliderScroller:(id)scroller1 itemTapped:(unsigned)tapped {
	DebugLog(@"itemTapped = %u", tapped);
	
	scroller = scroller1;
	indexTapped = tapped;
	//if (isUnlocking) {
		isToMulti = YES;
		appToOpen = [openApps objectAtIndex:tapped];
		DebugLog(@"appToOpen: %@", appToOpen);
		
		NSString* appDisplayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(appToOpen);
		if ([lockedApps containsObject:appToOpen]) {
			//NSLog(@"[Asos] appDisplayName: %@", appDisplayName);
			//SBApplication* appWithDisplay = [[SBApplication alloc] initWithBundleIdentifier:appToOpen];
			[handler showPasscodeViewWithBundleID:appToOpen andDisplayName:appDisplayName];
			/*
			[appSlider animateDismissalToDisplayIdentifier:@"com.apple.springboard" withCompletion:^{
			[[%c(SBUIController) sharedInstance] getRidOfAppSwitcher];
				}];
			UIAlertView* lockedAlert = [[UIAlertView alloc] initWithTitle:@"Asos" message:@"This app is locked. Please open it from the homescreen to 	input your passcode." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[lockedAlert show];
			return;
			*/
		}
		else {
			//NSLog(@"[Asos] %@ is not a locked app.", appDisplayName);
			%orig;
		}
	//}
	//else %orig;
}
- (id)_beginAppListAccess { 
	DebugLog0;
	openApps = %orig;
	//NSLog(@"[Asos] openApps is %@", openApps);
	return openApps;
}
%end


%hook SBAppSliderSnapshotView
+ (id)appSliderSnapshotViewForApplication:(SBApplication*)application orientation:(int)orientation loadAsync:(BOOL)async withQueue:(id)queue statusBarCache:(id)cache {
	if([lockedApps containsObject:[application bundleIdentifier]]){
		//UIImage* padlockImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Asos/padlock.png"];
		//UIImageView* padlockImageView = [[UIImageView alloc] initWithImage:padlockImage];

		UIImageView *snapshot = (UIImageView *)%orig();
		DebugLog(@"snapshot: %@", snapshot);
		//UIImage* snapshotImage = snapshot.image;
		CAFilter *filter = [CAFilter filterWithName:@"gaussianBlur"];
		[filter setValue:@10 forKey:@"inputRadius"];
		snapshot.layer.filters = [NSArray arrayWithObject:filter];
		//[snapshot addSubview:padlockImageView];
		/*
		UIGraphicsBeginImageContext(snapshotImage.size);
		[snapshotImage drawInRect:CGRectMake(0, 0, snapshotImage.size.width, snapshotImage.size.height)];
		[padlockImage drawInRect:CGRectMake(snapshotImage.size.width - padlockImage.size.width, snapshotImage.size.height - padlockImage.size.height, padlockImage.size.width, padlockImage.size.height)];
		UIImageView *result = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
		UIGraphicsEndImageContext();
		*/
		return snapshot;
	}
	return %orig;
}
%end

// END IOS7 COMPATIBILITY ------------------------------------>>>

// BEGIN IOS8 COMPATIBILITY ------------------------------------>>>



// END IOS 8 COMPATIBLITY ------------------------------------>>>

// Stratos Compatibility ------------------------------------>>>
%hook SBUIController
- (void)activateApplicationAnimated:(id)application {
	SBApplication* app = application;
	NSString *bundleID = [app bundleIdentifier];
	NSString *dispName = [app displayName];
	
	if ([lockedApps containsObject:bundleID]) {
		[[%c(SwitcherTrayView) sharedInstance] closeTray];
		
		if (!shouldLaunch) {
			[handler showPasscodeViewWithBundleID:bundleID andDisplayName:dispName];
		} else {
			%orig;
			shouldLaunch = NO;
			[handler.passcodeView reset];
		}
		
	} else {
		%orig;
		shouldLaunch = NO;
		[handler.passcodeView reset];
	}
}
%end

%hook SwitcherTrayCardView
- (id)initWithIdentifier:(NSString *)identifier {
	id tempTray = %orig;
	
	if ([lockedApps containsObject:identifier]) {
		UIView *blurView = [[UIView alloc] initWithFrame:[self frame]];
		[blurView setBackgroundColor:[UIColor redColor]];
		[tempTray addSubview:blurView];
	}
	return tempTray;

}
%end
//End Stratos Compatibility ---------------------------------<<<

void touchUnlock() {
	[handler removePasscodeView];
	BTTouchIDController* controller = [BTTouchIDController sharedInstance];
	[[UIApplication sharedApplication] launchApplicationWithIdentifier:controller.idToOpen suspended:NO];
	[controller stopMonitoring];
}

void touchFailed() {
	[handler.passcodeView resetFailedPass];
}

// Init ------------------------------------------------------------------------

%ctor {
	@autoreleasepool {
		NSLog(@" ASOS init.");
		
		loadPreferences();
		
		if (enabled) {
			DebugLogC(@"ASOS is enabled");
			
			handler = [[AsosPassShower alloc] init];
			timeLockedApps = [[NSMutableArray alloc] init];
			oncePerRespring = [[NSMutableArray alloc] init];
			openApps = [[NSMutableArray alloc] init];
			
			lockedApps = [[NSMutableArray alloc] init];
			
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
											NULL,
											(CFNotificationCallback)loadPreferences,
											CFSTR("com.phillipt.asos/settingschanged"),
											NULL,
											CFNotificationSuspensionBehaviorDeliverImmediately);
			
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
											NULL,
											(CFNotificationCallback)dismissToApp,
											CFSTR("com.phillipt.asos.multitaskEscape"),
											NULL,
											CFNotificationSuspensionBehaviorDeliverImmediately);

			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
											NULL,
											(CFNotificationCallback)touchUnlock,
											CFSTR("com.phillipt.asos.touchunlock"),
											NULL,
											CFNotificationSuspensionBehaviorDeliverImmediately);
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
											NULL,
											(CFNotificationCallback)touchFailed,
											CFSTR("com.phillipt.asos.touchfailed"),
											NULL,
											CFNotificationSuspensionBehaviorDeliverImmediately);

		} else {
			DebugLogC(@"ASOS is disabled");
		}
		
		dismissToApp();
	}
}

