//
//  Asos Settings
//
//  (c) 2014 Phillip Tennen.
//
//
#import "../BTTouchIDController.h"
#import <AudioToolbox/AudioServices.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <ManagedConfiguration/MCPasscodeManager.h>
#import "Interfaces.h"

#define DEBUG_PREFIX @" [ Asos : Prefs ]"
#import "../DebugLog.h"



//
// Interfaces
//
@interface AsosListController : PSListController <UIAlertViewDelegate>
- (void)applicationEnteredForeground:(id)something;
- (void)setEnabledSwitch:(id)value specifier:(PSSpecifier *)specifier;
- (void)setUseRealPasscodeSwitch:(id)value specifier:(PSSpecifier *)specifier;
- (void)setTimedPasscodeSwitch:(id)value specifier:(PSSpecifier *)specifier;
- (void)hidePasscodeAlert;
@end
@interface PSListController (Asos)
-(id)initForContentSize:(CGSize)arg1;
//IOS 8 EXCLUSIVE
-(void)popRecursivelyToRootController;
@end
@interface PSTableCell (Asos)
-(id)initWithStyle:(id)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3;
@end

@interface AsosListController ()
@property (nonatomic, strong, retain) UIBarButtonItem *respringButton;
@property (nonatomic, strong, retain) UIAlertView *passcodeAlert;
@property (nonatomic, strong, retain) UITextField *loginField;
@property (nonatomic, strong, retain) _UIBackdropView *blurView;
@property (nonatomic, strong, retain) PSSpecifier *passcodeInputSpecifier;
@property (nonatomic, strong, retain) PSSpecifier *timeInputSpecifier;
@property (nonatomic, assign) int randNum;
@property (nonatomic, assign) BOOL passcodeInputIsShowing;
@property (nonatomic, strong, retain) UITapGestureRecognizer *tapRecognizer;
@end

@interface AsosCustomCell : PSTableCell
@property (nonatomic, retain, strong) UIView* contentView;
@end

@interface Applications : PSListController
@end



//
// Globals
//
#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.phillipt.asos.plist"]
#define kSettingsIconPath	@"/Library/PreferenceBundles/Asos.bundle/Asos@2x.png"
#define kSettingsLogoPath	@"/Library/PreferenceBundles/Asos.bundle/Logo@2x.png"

__strong AsosListController *controller;

//
// Settings Controller
//

void prefsTouchUnlock() {
	NSLog(@"[Asos] fingerprint valid, unlock Prefs");
	[controller hidePasscodeAlert];
}

@implementation AsosListController

- (id)initForContentSize:(CGSize)size {
	NSLog(@"[Asos] settings init'd.");
	self = [super initForContentSize:size];
	NSLog(@"[Asos] self is %@", self);

	if (self) {
		NSLog(@"[Asos] IF self is %@", self);

		controller = self;
		_randNum = 0;
		_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];

		// add a Respring button to the navbar
		_respringButton = [[UIBarButtonItem alloc] 	initWithTitle:@"Respring"
								  					style:UIBarButtonItemStyleDone 
								  					target:self
								  					action:@selector(showRespringAlert)];		
		_respringButton.tintColor = [UIColor colorWithRed:212/255.0 green:86/255.0 blue:217/255.0 alpha:1];
		
		[self.navigationItem setRightBarButtonItem:_respringButton];
		
		
		// Show passcode lock alert whenever Preferences resumes from
		// background straight into Asos settings controller
		//Seems to be causing bugs, commenting out for now
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(applicationEnteredForeground:)
													 name:UIApplicationWillEnterForegroundNotification
												   object:nil];
		// listen for keypad to appear/disappear
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(passcodeInputKeypadDidShow)
													 name:UIKeyboardDidShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(passcodeInputKeypadDidHide)
													 name:UIKeyboardWillHideNotification
												   object:nil];

		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
											NULL,
											(CFNotificationCallback)prefsTouchUnlock,
											CFSTR("com.phillipt.asos.prefstouchunlock"),
											NULL,
											CFNotificationSuspensionBehaviorDeliverImmediately);
	}
	return self;
}
- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Asos" target:self];
		//DebugLog(@"read specifiers from plist: %@", _specifiers);
		
		self.timeInputSpecifier = [self specifierForID:@"timeInterval"];
		self.passcodeInputSpecifier = [self specifierForID:@"passcode"];
	}
	return _specifiers;
}
- (void)setTitle:(id)title {
	[super setTitle:title];
	
	UIImage *icon = [[UIImage alloc] initWithContentsOfFile:kSettingsIconPath];
	if (icon) {
		UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
		iconView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, iconView.frame.size.height);
		self.navigationItem.titleView = iconView;
	}
}
- (void)viewDidLoad {
	DebugLog0;
	[super viewDidLoad];
	
	[self showOrHideTimeInputCell];
	[self showOrHidePasscodeInputCell];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self showPasscodeAlert];
}

- (void)applicationEnteredForeground:(id)something {
	DebugLog0;
	
	[self showPasscodeAlert];
}
- (void)dealloc {
	// un-register for notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

//
- (void)setEnabledSwitch:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog(@"setting: %@ for key: %@", value, [specifier propertyForKey:@"key"]);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// indicate that a Respring is required
	self.respringButton.title = @"Respring";
}
- (void)setUseRealPasscodeSwitch:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog(@"setting: %@ for key: %@", value, [specifier propertyForKey:@"key"]);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	notify_post("com.phillipt.asos/settingschanged");
	
	[self showOrHidePasscodeInputCell];
}
- (void)setTimedPasscodeSwitch:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog(@"setting: %@ for key: %@", value, [specifier propertyForKey:@"key"]);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	notify_post("com.phillipt.asos/settingschanged");
	
	[self showOrHideTimeInputCell];
}

//
- (void)showRespringAlert {
	DebugLog0;
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Respring?"
						  message:@"Please Respring to enable or disable this tweak."
						  delegate:self
						  cancelButtonTitle:@"Cancel"
						  otherButtonTitles:@"Respring", nil];
	alert.tag = 996699;
	[alert show];
}
- (void)showPasscodeAlert {
	DebugLog0;
	
	// lazy load blur view
	if (!self.blurView) {
		self.blurView = [[_UIBackdropView alloc]	initWithFrame:CGRectZero
									   autosizesToFitSuperview:YES
													  settings:[_UIBackdropViewSettings settingsForPrivateStyle:3900]];
		
		[self.blurView setBlurQuality:@"low"];
		self.blurView.alpha = 0;
		
		[[[UIApplication sharedApplication] keyWindow] addSubview:self.blurView];
	}
	
	// lazy load passcode view
	if (!self.passcodeAlert) {
		self.passcodeAlert = [[UIAlertView alloc] 	initWithTitle:@"Asos"
														 message:@"Enter passcode or use Touch ID to access Asos settings"
														delegate:self
											   cancelButtonTitle:@"Cancel"
											   otherButtonTitles:@"Ok", nil];
		
		[self.passcodeAlert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
		
		if (!self.loginField) {
			self.loginField = [self.passcodeAlert textFieldAtIndex:0];
			[self.loginField setKeyboardType:UIKeyboardTypeNumberPad];
			self.loginField.autocorrectionType = UITextAutocorrectionTypeNo;
			self.loginField.enablesReturnKeyAutomatically = YES;
		}
	}
	
	// fade in blur, show the passcode alert
	[self.passcodeAlert show];

	//star monitoring Touch ID
	[[BTTouchIDController sharedInstance] startMonitoring];

	[UIView animateWithDuration:0.4 animations:^{
		self.blurView.alpha = 1.0;
	}];
}

- (void)hidePasscodeAlert; {
	DebugLog0;
	
	// dismiss alert, fade out blur
	[self.passcodeAlert dismissWithClickedButtonIndex:0 animated:YES];
	[UIView animateWithDuration:0.4 animations:^{
		self.blurView.alpha = 0;
	}];
	self.passcodeAlert = nil;
	self.blurView = nil;
	self.loginField = nil;

	[[BTTouchIDController sharedInstance] stopMonitoring];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	DebugLog(@"button clicked (%d) from alertView:%@", (int)buttonIndex, alertView);
	
	if (alertView.tag == 996699) { // Respring AlertView
		if (buttonIndex == alertView.firstOtherButtonIndex) {
			[self respring];
		}
	} 
	else { // Passcode Alert
		
		if (buttonIndex == alertView.cancelButtonIndex) { // Cancel button
			NSLog(@"[Asos] Hit cancel button");

			//IF is iOS 7
				[self.rootController popToRootViewControllerAnimated:YES];
			//ELSE IF is iOS 8
				[self.rootController popRecursivelyToRootController];
			//ENDIF

			NSLog(@"[Asos] rootController is %@", self.rootController);
			//NSLog(@"[Asos] pushedArray is %@", pushedArray);
			[self hidePasscodeAlert];
			
		} 
		else {
			UITextField *loginField = [alertView textFieldAtIndex:0];
			NSString *code = loginField.text;
			BOOL passIsValid = NO;
			NSError *error;
			
			if ([[self readPreferenceValue:[self specifierForID:@"useRealPass"]] boolValue]) {
				// using device PIN; use ManagedConfiguration to verify...
				
				Class $MC = NSClassFromString(@"MCPasscodeManager");
				DebugLog(@"$MC = %@", $MC);
				
				[[$MC sharedManager] unlockDeviceWithPasscode:code outError:&error];
				if (error) {
					//TODO: remove them form page if passcode is rejected
					//Done?
					DebugLog(@"passcode rejected by MC");
					//IF is iOS 7
						[self.rootController popToRootViewControllerAnimated:YES];
					//ELSE IF is iOS 8
						[self.rootController popRecursivelyToRootController];
					//ENDIF
				} else {
					DebugLog(@"passcode accepted by MC");
					passIsValid = YES;
				}
				
			} 
			else { // using custom passcode
				NSString *customPasscode = [self readPreferenceValue:[self specifierForID:@"passcode"]];
				if ([code isEqualToString:customPasscode]) {
					passIsValid = YES;
				}
			}
			
			if (passIsValid) {
				DebugLog(@"passcode valid, unlock Prefs");
				[self hidePasscodeAlert];
			} else {
				DebugLog(@"passcode invalid, buzz and bail");
				
				// wrong code, much vibration
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			
				//[self.rootController popViewControllerAnimated:YES];
				//IF is iOS 7
					[self.rootController popToRootViewControllerAnimated:YES];
				//ELSE IF is iOS 8
					[self.rootController popRecursivelyToRootController];
				//ENDIF
				[self hidePasscodeAlert];
			}
		}
	}
}
- (void)respring {
	NSLog(@"Asos called for a respring, bye-bye");
	system("killall backboardd");
}

//
- (void)showOrHideTimeInputCell {
	if ([[self readPreferenceValue:[self specifierForID:@"atTime"]] boolValue]) {
		// should show
		DebugLog(@"showing the time input specifier...");
		
		if ([self specifierForID:@"timeInterval"]) {
			DebugLog(@"> already showing");
		} else {
			[self 	insertSpecifier:self.timeInputSpecifier
					afterSpecifier:[self specifierForID:@"atTime"]
					animated:YES];
			DebugLog(@"> added");
		}
	} else {
		// should hide
		DebugLog(@"hiding the time input specifier...");
		[self removeSpecifier:self.timeInputSpecifier animated:YES];
	}
}
- (void)showOrHidePasscodeInputCell {
	if ([[self readPreferenceValue:[self specifierForID:@"useRealPass"]] boolValue]) {
		// should hide
		DebugLog(@"hiding the custom passcode input specifier...");
		[self removeSpecifier:self.passcodeInputSpecifier animated:YES];
	} else {
		// should show
		DebugLog(@"showing the passcode input specifier...");
		
		if ([self specifierForID:@"passcode"]) {
			DebugLog(@"> already showing");
		} else {
			[self 	insertSpecifier:self.passcodeInputSpecifier
					afterSpecifier:[self specifierForID:@"useRealPass"]
					animated:YES];
			DebugLog(@"> added");
		}
	}
}
- (void)passcodeInputKeypadDidShow {
	DebugLog0;
	self.passcodeInputIsShowing = YES;
	[self.view addGestureRecognizer:self.tapRecognizer];
}
- (void)passcodeInputKeypadDidHide {
	DebugLog0;
	self.passcodeInputIsShowing = NO;
	[self.view removeGestureRecognizer:self.tapRecognizer];
}
- (void)tap:(UIGestureRecognizer *)caller {
	DebugLog0;
	if (self.passcodeInputIsShowing) {
		[self.view endEditing:YES];
	}
}

@end

//
// Logo Cell
//
@implementation AsosCustomCell
- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"ASOSCustomCell"
					  specifier:specifier];
	if (self) {
		UIImage *logo = [[UIImage alloc] initWithContentsOfFile:kSettingsLogoPath];
		if (logo) {
			UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
			[self addSubview:logoView];
		}
		
		UILabel *randomLabel = [[UILabel alloc] initWithFrame:self.contentView.frame];
		randomLabel.text = [self randomString];
		randomLabel.font = [UIFont systemFontOfSize:10];
		randomLabel.textColor = UIColor.whiteColor;
	}
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
	return 130.0f;
}
- (NSString *)randomString {
	NSArray *strings = @[
		@"Thank you for your purchase.",
		@"Enjoy.",
		@"From Phillip Tennen and the Cortex Dev Team",
		@"Use responsibly.",
		@"Follow @phillipten on Twitter.",
		@"Follow @phillipt on Twitter.",
		@"We love you /r/jailbreak!",
		@"Is this thing on?"
		];
	
	if (controller.randNum < 0 || controller.randNum > strings.count) {
		controller.randNum = 0;
	}
	NSString *saying = strings[controller.randNum];
	DebugLog(@"RandomString chosen (%d): %@", controller.randNum, saying);
	
	controller.randNum++;
	
	return saying;
}
@end

