#import <Preferences/Preferences.h>

@interface AsosListController: PSListController {
}
@end

@implementation AsosListController
- (id)specifiers {
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
