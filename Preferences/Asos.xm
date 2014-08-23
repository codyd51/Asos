#import <Preferences/Preferences.h>
#import <AudioToolbox/AudioServices.h>
#import <notify.h>
#import "Interfaces.h"
#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.phillipt.asos.plist"]

@interface AsosListController: PSListController <UIAlertViewDelegate> {
}
@property (assign) NSMutableDictionary* prefs;
@end

UITextField *loginField;
_UIBackdropView *blurView;
UIView* sbWindow;

@implementation AsosListController
@synthesize prefs;
- (id)specifiers {
	prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];

	sbWindow = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self.view addSubview:sbWindow];
	[sbWindow setBackgroundColor:[UIColor clearColor]];

	SBUIPasscodeLockViewSimple4DigitKeypad* passcodeView = [[%c(SBUIPasscodeLockViewSimple4DigitKeypad) alloc] init];
	passcodeView.frame = [[UIScreen mainScreen] bounds];
	_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForPrivateStyle:3900];
	blurView = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];

	blurView.alpha = 0;
	blurView.userInteractionEnabled=NO;
	[blurView setBlurQuality:@"default"];

	[sbWindow addSubview:blurView];

	[UIView animateWithDuration:0.4 animations:^{
		blurView.alpha = 1.0;
	}];

	if (([self.prefs objectForKey:@"passcode"] != nil || [self.prefs objectForKey:@"useRealPass"] != nil) && [[self.prefs objectForKey:@"enabled"] boolValue]) {
		UIAlertView* loginAlert = [[UIAlertView alloc] initWithTitle:@"Asos" message:@"Enter passcode to access Asos settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
		[loginAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
		loginField = [loginAlert textFieldAtIndex:0];
		[loginField setKeyboardType:UIKeyboardTypeNumberPad];
		loginField.autocorrectionType = UITextAutocorrectionTypeNo;
		loginField.enablesReturnKeyAutomatically = YES;
		[loginField setPlaceholder:@"15"];
		[loginAlert  show];
	}

	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Asos" target:self] retain];
	}
	return _specifiers;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString* passToUse;

	prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath];
	NSLog(@"[Asos] prefs is %@", prefs);

	BOOL useRealPass = NO;
	NSString* settingsPass = [prefs objectForKey:@"passcode"];
	if (useRealPass) passToUse = prefs[@"userPass"];
	//else if (settingsPass) passToUse = settingsPass;

	if (buttonIndex != alertView.cancelButtonIndex) {
		if ([loginField.text isEqualToString:prefs[@"passcode"]] || [loginField.text isEqualToString:prefs[@"userPass"]]) {
			[UIView animateWithDuration:0.8 animations:^{
				blurView.alpha = 0.0;
				[blurView removeFromSuperview];
				[sbWindow removeFromSuperview];
				blurView = nil;
				sbWindow = nil;
			}];
		}
		else {
			[self.rootController popViewControllerAnimated:YES];
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		}
	}
	else {
		[self.rootController popViewControllerAnimated:YES];
	}
}
@end

@interface Applications: PSListController {
}
@end

// vim:ft=objc
