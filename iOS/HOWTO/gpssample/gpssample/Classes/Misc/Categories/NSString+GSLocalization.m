//
//  NSString+GSLocalization.m
//  gpssample
//
//  Created by Sergey Mamontov on 3/30/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSString+GSLocalization.h"


#pragma mark Static

// Stores code of the language to which fallback will be provided
static NSString* const kGSLocalizationFallbackLanguage = @"en";


#pragma mark Public interface implementation

@implementation NSString (GSLocalization)


#pragma mark - Instance methods

- (NSString *)localized {
    
    static NSBundle *languageBundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Retrieve preferred application language
		NSString *langCode = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        // Check whether resources found for this language or not
		if([[NSBundle mainBundle] pathForResource:langCode ofType:@"lproj"] == nil) {
            
            langCode = kGSLocalizationFallbackLanguage;
        }
        
        languageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:langCode ofType:@"lproj"]];
    });
    
    
    return [languageBundle localizedStringForKey:self value:self table:nil];
}

#pragma mark -


@end
