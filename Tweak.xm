//
//  ASOS
//
//

#import <objc/runtime.h>
#import <AudioToolbox/AudioServices.h>
#import "Interfaces.h"
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
- (void)passcodeLockNumberPadCancelButtonHit:(id)arg1;
- (void)passcodeLockNumberPadBackspaceButtonHit:(id)arg1;
@end
@interface SBUIPasscodeLockViewSimple4DigitKeypad : SBUIPasscodeLockViewWithKeypad
- (double)_entryFieldBottomYDistanceFromNumberPadTopButton;
- (id)_newEntryField;
- (id)init;
@end

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



//
// Globals
//

#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.cortexdevteam.asos.plist"]

@class ASOSPassShower;
static ASOSPassShower *handler;

static NSMutableDictionary* prefs;
static NSMutableArray* lockedApps;
static NSMutableArray* timeLockedApps;
static NSMutableArray* oncePerRespring;
static NSMutableArray* openApps;

static id appSlider;
static id menuButtonDownStamp;
static id scroller;
static UITextField* passcodeField;
//static UIView* key = [[UIView alloc] init];
//static UIWindow *aboveWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];

static NSString* appToOpen;
static NSString* bundleID;
static NSString *currentlyOpening;
static NSString* dispName ;
static NSString* settingsPass;
static NSString* tempString;
static NSString* timeInterval;
static NSString* userPass;

static BOOL isFromMulti;
static BOOL isToMulti;
static BOOL isUnlocking = YES;
static BOOL shouldLaunch;
static int indexTapped;


// Default Settings
static BOOL enabled = YES;
static BOOL useRealPass = YES;
static BOOL atTime;
static BOOL onceRespring;





//
// Interfaces
//

@interface ASOSPasscodeView : SBUIPasscodeLockViewSimple4DigitKeypad
@end


@interface ASOSPassShower : NSObject <UIAlertViewDelegate>
@property (nonatomic, strong) ASOSPasscodeView *passcodeView;
@property (nonatomic, strong) _UIBackdropView *blurView;
- (void)showPassViewWithBundleID:(NSString *)passedID andDisplayName:(NSString *)passedDisplayName;
@end





//
// Helpers
//

void loadPreferences() {
	DebugLogC(@"loadPreferences()");
	
	[lockedApps removeAllObjects];
	
	prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];
	DebugLogC(@"read prefs from disk: %@", prefs);
	
	if (prefs) {
		// populate lockedApps array
		for (NSString *key in [prefs allKeys]) {
			if ([[prefs objectForKey:key] boolValue]) {
				if ([key rangeOfString:@"lock-"].location != NSNotFound) {
					NSString *trimmedString = [key substringFromIndex:5];
					[lockedApps addObject:trimmedString];
				}
			}
		}
		
		if (prefs[@"enabled"]) {
			enabled = [prefs[@"enabled"] boolValue];
		}
		DebugLogC(@"setting for enabled:%d", enabled);
		
		if ([prefs objectForKey:@"useRealPass"]) {
			useRealPass = [[prefs objectForKey:@"useRealPass"] boolValue];
		}
		DebugLogC(@"setting for useRealPass:%d", useRealPass);
		
		if ([prefs objectForKey:@"onceRespring"]) {
			onceRespring = [[prefs objectForKey:@"onceRespring"] boolValue];
		}
		DebugLogC(@"setting for onceRespring:%d", onceRespring);
		
		if ([prefs objectForKey:@"atTime"]) {
			atTime = [[prefs objectForKey:@"atTime"] boolValue];
		}
		DebugLogC(@"setting for atTime:%d", atTime);
		
		if ([prefs objectForKey:@"timeInterval"]) {
			int timeToLock = [[prefs objectForKey:@"timeInterval"] intValue] * 60;
			timeInterval = [NSString stringWithFormat:@"%i", timeToLock];
		}
		DebugLogC(@"setting for timeInterval:%@", timeInterval);
		
		settingsPass = [prefs objectForKey:@"passcode"];
		DebugLogC(@"setting for settingsPass:%@", settingsPass);
	}
}

void dismissToApp() {
	if (isToMulti) {
		isUnlocking = NO;
		[appSlider sliderScroller:scroller itemTapped:indexTapped];
		isUnlocking = YES;
		[appSlider animateDismissalToDisplayIdentifier:appToOpen withCompletion:nil];
		isToMulti = NO;
	}
}





//
// PasscodeView Class
//
@implementation ASOSPasscodeView
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
			notify_post("com.cortexdevteam.asos.multitaskEscape");
			
			// dismiss the passcode view
			[UIView animateWithDuration:0.4 animations:^{
				handler.passcodeView.statusTitleView.text = @"✓";
				handler.passcodeView.alpha = 0;
				handler.blurView.alpha = 0;
				//[passcodeView removeFromSuperview];
			}];
			
			// continue launching the app
			[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];
				
		} else {
			DebugLog(@"...passcode was INVALID.");
			// To fix the last bubble not dissapearing
			if (!isFromMulti) {
				[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(resetFailedPass) userInfo:nil repeats:NO];
			} else {
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
	}];
	[UIView animateWithDuration:0.5 animations:^{
		handler.passcodeView.statusTitleView.text = [NSString stringWithFormat:@"Enter Passcode to open %@", dispName];
	}];
	
	[self resetForFailedPasscode];
}
@end





//
// PassShower Class
//
@implementation ASOSPassShower
- (instancetype)init {
	DebugLog0;
	
	self = [super init];
	if (self ) {
		_blurView = [[_UIBackdropView alloc] initWithFrame:CGRectZero
								   autosizesToFitSuperview:YES settings:[_UIBackdropViewSettings settingsForPrivateStyle:3900]];
		[_blurView setBlurQuality:@"default"];
		_blurView.alpha = 0;
		
		_passcodeView = [[ASOSPasscodeView alloc] init];
	}
	return self;
}
- (void)showPassViewWithBundleID:(NSString *)passedID andDisplayName:(NSString *)passedDisplayName {
	DebugLog(@"showPassView for: %@ [%@]", passedDisplayName, passedID);
	
	currentlyOpening = passedID;
	[self.passcodeView reset];
	self.passcodeView.statusTitleView.text = [NSString stringWithFormat:@"Enter Passcode to open %@", passedDisplayName];
	
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	[window addSubview:self.blurView];
	[window addSubview:self.passcodeView];
	
	[UIView animateWithDuration:0.4 animations:^{
		self.passcodeView.alpha = 1.0;
		self.blurView.alpha = 1.0;
	}];
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
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
		alertView = nil;
		[UIView animateWithDuration:0.4 animations:^{
			self.blurView.alpha = 1.0;
		}];
		notify_post("com.cortexdevteam.asos.settings-pop-vc");
		
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
			[UIView animateWithDuration:0.4 animations:^{
				self.blurView.alpha = 1.0;
			}];
			
		} else {
			// wrong code, much vibration
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		}
	}
}
@end





// H00KS ///////////////////////////////////////////////////////////////////////


%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
	DebugLog0;
	%orig;
	
	notify_post("com.cortexdevteam.asos/settingschanged");
	loadPreferences();
}
- (void)_menuButtonDown:(id)arg1 {
	DebugLog0;
	menuButtonDownStamp = arg1;
	%orig;
}
%end



//
// Save the user's passcode when they use the actual LockScreen.
//
/*
%hook SBLockScreenManager
- (BOOL)attemptUnlockWithPasscode:(id)arg1 {
	DebugLog(@"attemptUnlockWithPasscode:%@", arg1);
	
	BOOL didSucceed = %orig;
	if (didSucceed) {
		userPass = (NSString*)arg1;
		
		if (!prefs) {
			prefs = [[NSMutableDictionary alloc] init];
		}
		
		prefs[@"userPass"] = userPass;
		DebugLog(@"writing prefs: %@", prefs);
		[prefs writeToFile:kSettingsPath atomically:YES];
	}
	return didSucceed;
}
%end
*/

//
// Unlock a locked app...
//
/*
%hook SBUIPasscodeLockViewWithKeypad
- (void)passcodeEntryFieldTextDidChange:(id)arg1 {
	DebugLog(@"SBUIPasscodeLockViewWithKeypad::passcodeEntryFieldTextDidChange");
	
	// Only touch our passcode view
	if (self == handler.passcodeView) {
		
		// check pass after the 4th key press...
		if ([[self passcode] length] == 4) {
			
			enteredCorrectPass = NO;
			
			if (!useRealPass) {
				if (!settingsPass) {
					// no passcode set for Asos, show alert
					UIAlertView* noPassAlert = [[UIAlertView alloc] initWithTitle:@"Asos" message:@"Please configure your passcode settings in Asos preferences." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[noPassAlert show];
				} else {
					// test custom passcode
					if ([[self passcode] isEqualToString:settingsPass]) {
						enteredCorrectPass = YES;
					}
				}
				
			} else {
				// test real pass
				if ([[%c(SBDeviceLockController) sharedController] attemptDeviceUnlockWithPassword:[self passcode] appRequested:nil]) {
					enteredCorrectPass = YES;
				}
			}
			
			// was the passcode valid for Asos?
			if (enteredCorrectPass) {
				
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
				notify_post("com.cortexdevteam.asos.multitaskEscape");
				
				// dismiss the passcode view
				[UIView animateWithDuration:0.4 animations:^{
					handler.passcodeView.statusTitleView.text = @"✓";
					handler.passcodeView.alpha = 0;
					handler.blurView.alpha = 0;
					//[passcodeView removeFromSuperview];
				}];
				[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];
				
			} else {
				// To fix the last bubble not dissapearing
				if (!isFromMulti) {
					[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(resetFailedPass) userInfo:nil repeats:NO];
				} else {
					UIAlertView* homeAlert = [[UIAlertView alloc] initWithTitle:@"Testing" message:@"Should exit to homescreen now." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[homeAlert show];
					SpringBoard* spring = (SpringBoard*)[UIApplication sharedApplication];
					[spring _handleMenuButtonEvent];
					[self resetForFailedPasscode];
					isFromMulti = NO;
				}
			}
		}
	}
	
	%orig;
}
- (void)passcodeLockNumberPadCancelButtonHit:(id)arg1 {
	DebugLog(@"SBUIPasscodeLockViewWithKeypad::passcodeLockNumberPadCancelButtonHit");
	
	if ([self tag] == 1337) {
		[UIView animateWithDuration:0.3 animations:^{
			handler.passcodeView.alpha = 0;
			handler.blurView.alpha = 0;
		}];
	}
	%orig;
}
- (void)passcodeLockNumberPadBackspaceButtonHit:(id)arg1 {
	DebugLog(@"SBUIPasscodeLockViewWithKeypad::passcodeLockNumberPadBackspaceButtonHit");
	
	//To fix the last number still being filled
	if ([self tag] == 1337) {
		if ([[self passcode] length] == 0) [self reset];
	}
	%orig;
}
%new
- (void)resetFailedPass {
	DebugLog(@"SBUIPasscodeLockViewWithKeypad::resetFailedPass");
	
	[UIView animateWithDuration:0.5 animations:^{
		handler.passcodeView.statusTitleView.text = @"✗";
	}];
	[UIView animateWithDuration:0.5 animations:^{
		handler.passcodeView.statusTitleView.text = [NSString stringWithFormat:@"Enter Passcode to open %@", dispName];
	}];
	
	[self resetForFailedPasscode];
}
%end
*/



// App Launching Hooks ---------------------------------------------------------

%hook SBApplicationIcon
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
			[handler showPassViewWithBundleID:bundleID andDisplayName:dispName];
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
%end


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
	if (isUnlocking) {
		isToMulti = YES;
		appToOpen = [openApps objectAtIndex:tapped];
		DebugLog(@"appToOpen: %@", appToOpen);
		
		if ([lockedApps containsObject:appToOpen]) {
			NSString* appDisplayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(appToOpen);
			//SBApplication* appWithDisplay = [[SBApplication alloc] initWithBundleIdentifier:appToOpen];
			[handler showPassViewWithBundleID:appToOpen andDisplayName:appDisplayName];
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
	DebugLog0;
	openApps = %orig;
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



// Stratos Compatibility -------------------------------------------------------

%hook SBUIController
- (void)activateApplicationAnimated:(id)application {
	SBApplication* app = application;
	NSString *bundleID = [app bundleIdentifier];
	NSString *dispName = [app displayName];
	
	if ([lockedApps containsObject:bundleID]) {
		[[%c(SwitcherTrayView) sharedInstance] closeTray];
		
		if (!shouldLaunch) {
			[handler showPassViewWithBundleID:bundleID andDisplayName:dispName];
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

//End Stratos Compatibility ----------------------------------------------------





//
// Init
//
%ctor {
	@autoreleasepool {
		NSLog(@" ASOS init.");
		
		loadPreferences();
		
		if (enabled) {
			DebugLogC(@"ASOS is enabled");
			
			handler = [[ASOSPassShower alloc] init];
			lockedApps = [[NSMutableArray alloc] init];
			timeLockedApps = [[NSMutableArray alloc] init];
			oncePerRespring = [[NSMutableArray alloc] init];
			openApps = [[NSMutableArray alloc] init];
			
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
											NULL,
											(CFNotificationCallback)loadPreferences,
											CFSTR("com.cortexdevteam.asos/settingschanged"),
											NULL,
											CFNotificationSuspensionBehaviorDeliverImmediately);
			
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
											NULL,
											(CFNotificationCallback)dismissToApp,
											CFSTR("com.cortexdevteam.asos.multitaskEscape"),
											NULL,
											CFNotificationSuspensionBehaviorDeliverImmediately);
		} else {
			DebugLogC(@"ASOS is disabled");
		}
		
		dismissToApp();
	}
}

