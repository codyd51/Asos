//
//  ASOS
//

#import "Interfaces.h"
#import <objc/runtime.h>

#ifdef DEBUG
#define DebugLog(s, ...) NSLog(@" [Asos] >> %@", [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define DebugLog(s, ...)
#endif


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

//typedef void(^passCompletion)(BOOL);

#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.phillipt.asos.plist"]

static PassShower* handler;
static NSMutableDictionary* prefs;

static UITextField* passcodeField;
static SBUIPasscodeLockViewSimple4DigitKeypad* passcodeView = [[%c(SBUIPasscodeLockViewSimple4DigitKeypad) alloc] init];
static _UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForPrivateStyle:3900];
static _UIBackdropView *blurView = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];
static BOOL shouldLaunch = NO;
static NSString* bundleID = @"";
static NSString* dispName = @"";
static NSMutableArray* lockedApps = [[NSMutableArray alloc] init];
static NSMutableArray* oncePerRespring = [[NSMutableArray alloc] init];
static NSMutableArray* timeLockedApps = [[NSMutableArray alloc] init];
static UIView* key = [[UIView alloc] init];
static id menuButtonDownStamp;
static BOOL isFromMulti = NO;
static id appSlider;
static NSMutableArray* openApps = [[NSMutableArray alloc] init];
static NSString* tempString = @"";
static NSString* userPass = @"";
static BOOL enabled = YES;
static BOOL useRealPass = YES;
static BOOL enteredCorrectPass;
static BOOL isToMulti;
static BOOL isUnlocking = YES;
static BOOL onceRespring = NO;
static BOOL atTime;
static NSString* timeInterval;
static NSString* settingsPass;
static NSString* appToOpen;
static NSString* currentlyOpening;
//CGRect bounds = [[UIScreen mainScreen] bounds];
//UIWindow *aboveWindow = [[UIWindow alloc] initWithFrame:bounds];
static UIWindow *aboveWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];


@implementation PassShower
- (void)showPassViewWithBundleID:(NSString*)passedID andDisplayName:(NSString*)passedDisplayName toWindow:(UIView*)window {
	DebugLog(@"show pass view");
	
	passedID = currentlyOpening;
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
- (void)removeLocked {
	DebugLog(@"removeLocked");
	
	id removeObject = [timeLockedApps objectAtIndex:0];
	[lockedApps addObject:removeObject];
	[timeLockedApps removeObject:removeObject];
	//[lockedApps addObject:[self associatedObject]];
	//[timeLockedApps removeObject:[self associatedObject]];
}
@end





%hook SBApplicationIcon
- (void)launchFromLocation:(int)location {
	DebugLog(@"SBApplicationIcon::launchFromLocation");

	SBApplication* app = (SBApplication*)[self application];
	bundleID = [app bundleIdentifier];
	DebugLog(@"app id: %@", bundleID);
	
	currentlyOpening = bundleID;
	dispName = [self displayName];
	
	if ([lockedApps containsObject:bundleID] && ![oncePerRespring containsObject:bundleID]) {
		key = [[UIApplication sharedApplication] keyWindow];

		if (!shouldLaunch) {
			DebugLog(@"showing pass view...");
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
	DebugLog(@"SBUIPasscodeLockViewWithKeypad::passcodeEntryFieldTextDidChange");
	
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
				//[self resetForFailedPasscode];
			}
		}
	}
	%orig;
}

- (void)passcodeLockNumberPadCancelButtonHit:(id)arg1 {
	DebugLog(@"SBUIPasscodeLockViewWithKeypad::passcodeLockNumberPadCancelButtonHit");
	
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
	DebugLog(@"SBUIPasscodeLockViewWithKeypad::passcodeLockNumberPadBackspaceButtonHit");
	
	//To fix the last number still being filled
	if ([self tag] == 1337) {
		if ([[self passcode] length] == 0) [self reset];
	}
	%orig;
}

%new
-(void)resetFailedPass {
	DebugLog(@"SBUIPasscodeLockViewWithKeypad::resetFailedPass");
	
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
	DebugLog(@"read prefs from disk: %@", prefs);
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
	if ([prefs objectForKey:@"onceRespring"] != nil) onceRespring = [[prefs objectForKey:@"onceRespring"] boolValue];
	if ([prefs objectForKey:@"atTime"] != nil) atTime = [[prefs objectForKey:@"atTime"] boolValue];
	if ([prefs objectForKey:@"timeInterval"] != nil) {
		int timeToLock = [[prefs objectForKey:@"timeInterval"] intValue] * 60;
		timeInterval = [NSString stringWithFormat:@"%i", timeToLock];
	}
	settingsPass = [prefs objectForKey:@"passcode"];
}




%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	DebugLog(@"SpringBoard::applicationDidFinishLaunching");
	%orig;
	notify_post("com.phillipt.asos/settingschanged");
	loadPreferences();
}

-(void)menuButtonDown:(id)arg1 {
	DebugLog(@"SpringBoard::menuButtonDown(%@)", arg1);
	%orig;
}

-(void)_menuButtonDown:(id)arg1 {
	DebugLog(@"SpringBoard::_menuButtonDown(%@)", arg1);
	menuButtonDownStamp = arg1;
	%orig;
}

%end



id scroller;
int indexTapped;

%hook SBAppSliderController
- (id)init {
	DebugLog(@"SBAppSliderController::init");
	appSlider = %orig;
	return appSlider;
}
- (void)sliderScroller:(id)scroller1 itemTapped:(unsigned)tapped {
	DebugLog(@"SBAppSliderController::slidederScroller:itemTapped (%u)", tapped);
	
	scroller = scroller1;
	indexTapped = tapped;
	if (isUnlocking) {
		isToMulti = YES;
		key = [[UIApplication sharedApplication] keyWindow];
		appToOpen = [openApps objectAtIndex:tapped];
		DebugLog(@"itemTapped: %@", appToOpen);
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
	DebugLog(@"SBAppSliderController::_beginAppListAccess");
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
		DebugLog(@"[Asos] Snapshot: %@", snapshot);
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



//Start Stratos Compatibility
%hook SBUIController
- (void)activateApplicationAnimated:(id)application {
	SBApplication* app = application;
	bundleID = [app bundleIdentifier];
	dispName = [app displayName];

	if ([lockedApps containsObject:bundleID]) {
		[[%c(SwitcherTrayView) sharedInstance] closeTray];
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
//End Stratos Compatibility



void dismissToApp() {
	if (isToMulti) {
		isUnlocking = NO;
		[appSlider sliderScroller:scroller itemTapped:indexTapped];
		isUnlocking = YES;
		[appSlider animateDismissalToDisplayIdentifier:appToOpen withCompletion:nil];
		isToMulti = NO;
	}
}



// Init //
%ctor {
	@autoreleasepool {
		handler = [[PassShower alloc] init];
		
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
}

