#import <Preferences/Preferences.h>
#import <notify.h>
#import <objc/runtime.h>
#import "Interfaces.h"
#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.phillipt.asos.plist"]

@interface AsosListController: PSListController {
}
@property (assign) NSMutableDictionary* prefs;
@end

@implementation AsosListController
@synthesize prefs;
- (id)specifiers {
	//if (([self.prefs objectForKey:@"passcode"] != nil || [self.prefs objectForKey:@"useRealPass"] != nil) && [[self.prefs objectForKey:@"enabled"] boolValue]) {
		NSLog(@"[Asos] notify_post from specifiers");
		notify_post("com.phillipt.asos.prefsShow");
		UIViewController* viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
		UIView* sbWindow = [[UIView alloc] initWithFrame:[self.view frame]];
		[viewController setView:sbWindow];
		[self.view addSubview:sbWindow];

		SBUIPasscodeLockViewSimple4DigitKeypad* passcodeView = [[objc_getClass("SBUIPasscodeLockViewSimple4DigitKeypad") alloc] init];
		_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForPrivateStyle:3900];
		_UIBackdropView *blurView = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];

		passcodeView.userInteractionEnabled = YES;
		passcodeView.shouldResetForFailedPasscodeAttempt = YES;
		passcodeView.backgroundColor = [UIColor clearColor];
		passcodeView.backgroundAlpha = 0.9;
		passcodeView.alpha = 0;
		passcodeView.userInteractionEnabled = YES;
		passcodeView.statusTitleView.text = @"Enter Passcode to open Asos Settings";
		passcodeView.showsEmergencyCallButton = NO;
		passcodeView.tag = 1337;
		[passcodeView reset];

		blurView.alpha = 0;
		[blurView setBlurQuality:@"default"];

		[sbWindow addSubview:blurView];
		[sbWindow addSubview:passcodeView];

		[UIView animateWithDuration:0.4 animations:^{
			passcodeView.alpha = 1.0;
			blurView.alpha = 1.0;
		}];
	//}
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Asos" target:self] retain];
	}
	return _specifiers;
}
@end

@interface Applications: PSListController {
}
@end

// vim:ft=objc
