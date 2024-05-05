//
//  UIFont+OHAdditions.m
//  AttributedStringDemo
//
//  Created by Olivier Halligon on 16/08/2014.
//  Copyright (c) 2014 AliSoftware. All rights reserved.
//

#import "UIFont+OHAdditions.h"

@implementation KBFont (OHAdditions)

+ (instancetype)fontWithFamily:(NSString*)fontFamily
                          size:(CGFloat)size
                          bold:(BOOL)isBold
                        italic:(BOOL)isItalic
{
    KBFontDescriptorSymbolicTraits traits = 0;
    if (isBold) traits |= NSFontDescriptorTraitBold;
    if (isItalic) traits |= NSFontDescriptorTraitItalic;
    
    return [self fontWithFamily:fontFamily size:size traits:traits];
}

+ (instancetype)fontWithFamily:(NSString*)fontFamily
                          size:(CGFloat)size
                        traits:(KBFontDescriptorSymbolicTraits)symTraits
{
    NSDictionary* attributes = @{ KBFontFamilyAttribute: fontFamily,
                                  KBFontTraitsAttribute: @{KBFontSymbolicTrait:@(symTraits)}};
    
    KBFontDescriptor* desc = [KBFontDescriptor fontDescriptorWithFontAttributes:attributes];
    return (KBFont*)[KBFont fontWithDescriptor:desc size:size];
}

+ (instancetype)fontWithPostscriptName:(NSString*)postscriptName size:(CGFloat)size
{
    // UIFontDescriptorNameAttribute = Postscript name, should not change across iOS versions.
    NSDictionary* attributes = @{ KBFontNameAttribute: postscriptName };
    
    KBFontDescriptor* desc = [KBFontDescriptor fontDescriptorWithFontAttributes:attributes];
    return (KBFont*)[KBFont fontWithDescriptor:desc size:size];
}

- (instancetype)fontWithSymbolicTraits:(KBFontDescriptorSymbolicTraits)symTraits
{
    NSDictionary* attributes = @{KBFontFamilyAttribute: self.familyName,
                                 KBFontTraitsAttribute: @{KBFontSymbolicTrait:@(symTraits)}};
    KBFontDescriptor* desc = [KBFontDescriptor fontDescriptorWithFontAttributes:attributes];
    return (KBFont*)[KBFont fontWithDescriptor:desc size:self.pointSize];
}

- (KBFontDescriptorSymbolicTraits)symbolicTraits
{
    return self.fontDescriptor.symbolicTraits;
}

@end
