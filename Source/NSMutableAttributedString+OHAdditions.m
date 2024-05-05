/*******************************************************************************
 * This software is under the MIT License quoted below:
 *******************************************************************************
 *
 * Copyright (c) 2010 Olivier Halligon
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ******************************************************************************/


#import "NSMutableAttributedString+OHAdditions.h"
#import "NSAttributedString+OHAdditions.h"
#import "UIFont+OHAdditions.h"

@implementation NSMutableAttributedString (OHAdditions)

+ (instancetype)attributedStringWithAttributedString:(NSAttributedString *)attrStr addingAttributes:(NSDictionary *)attributes {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
    [string addAttributes:attributes range:NSMakeRange(0, string.length)];
    return string;
}

- (void)appendString:(NSString *)string {
    [self appendAttributedString:[NSAttributedString attributedStringWithString:string]];
}

- (void)appendFormat:(NSString*)format, ... {
    va_list args;
    va_start(args, format);
    NSString* string = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [self appendString:string];
}

+ (instancetype)attributedStringWithFormat:(NSString*)format, ...
{
    va_list args;
    va_start(args, format);
    NSString* string = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [[self alloc] initWithString:string];
}

/******************************************************************************/
#pragma mark - Text Font

- (void)setFont:(KBFont*)font
{
	[self setFont:font range:NSMakeRange(0, self.length)];
}

- (void)setFont:(KBFont*)font range:(NSRange)range
{
    if (font)
    {
        [self removeAttribute:NSFontAttributeName range:range]; // Work around for Apple leak
        [self addAttribute:NSFontAttributeName value:(id)font range:range];
    }
}


/******************************************************************************/
#pragma mark - Text Color

- (void)setTextColor:(KBColor*)color
{
	[self setTextColor:color range:NSMakeRange(0,self.length)];
}

- (void)setTextColor:(KBColor*)color range:(NSRange)range
{
	[self removeAttribute:NSForegroundColorAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:NSForegroundColorAttributeName value:(id)color range:range];
}

- (void)setTextBackgroundColor:(KBColor*)color
{
    [self setTextBackgroundColor:color range:NSMakeRange(0, self.length)];
}

- (void)setTextBackgroundColor:(KBColor*)color range:(NSRange)range
{
	[self removeAttribute:NSBackgroundColorAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:NSBackgroundColorAttributeName value:(id)color range:range];
}

/******************************************************************************/
#pragma mark - Text Underlining

- (void)setTextUnderlined:(BOOL)underlined
{
	[self setTextUnderlined:underlined range:NSMakeRange(0,self.length)];
}

- (void)setTextUnderlined:(BOOL)underlined range:(NSRange)range
{
	NSUnderlineStyle style = underlined ? (NSUnderlineStyleSingle|NSUnderlinePatternSolid) : NSUnderlineStyleNone;
	[self setTextUnderlineStyle:style range:range];
}

- (void)setTextUnderlineStyle:(NSUnderlineStyle)style range:(NSRange)range
{
	[self removeAttribute:NSUnderlineStyleAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:NSUnderlineStyleAttributeName value:@(style) range:range];
}

- (void)setTextUnderlineColor:(KBColor*)color
{
    [self setTextUnderlineColor:color range:NSMakeRange(0, self.length)];
}

- (void)setTextUnderlineColor:(KBColor*)color range:(NSRange)range
{
	[self removeAttribute:NSUnderlineColorAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:NSUnderlineColorAttributeName value:color range:range];
}

/******************************************************************************/
#pragma mark - Text Style & Traits

- (void)changeFontTraitsWithBlock:(KBFontDescriptorSymbolicTraits(^)(KBFontDescriptorSymbolicTraits, NSRange))block
{
    [self changeFontTraitsInRange:NSMakeRange(0, self.length)
                        withBlock:block];
}

- (void)changeFontTraitsInRange:(NSRange)range
                      withBlock:(KBFontDescriptorSymbolicTraits(^)(KBFontDescriptorSymbolicTraits, NSRange))block
{
    NSParameterAssert(block);
    [self beginEditing];
    [self enumerateFontsInRange:range
               includeUndefined:YES
                     usingBlock:^(KBFont* font, NSRange aRange, BOOL *stop)
     {
         if (!font) font = [[self class] defaultFont];
         KBFontDescriptorSymbolicTraits currentTraits = font.symbolicTraits;
         KBFontDescriptorSymbolicTraits newTraits = block(currentTraits, aRange);
         KBFont* newFont = [font fontWithSymbolicTraits:newTraits];
         [self setFont:newFont range:aRange];
     }];
    [self endEditing];
}

- (void)setFontBold:(BOOL)isBold
{
    [self setFontBold:isBold range:NSMakeRange(0, self.length)];
}

// TODO: Check out the effect of the NSStrokeWidthAttributeName attribute
//       to see if we can also fake bold fonts by increasing the font weight
- (void)setFontBold:(BOOL)isBold range:(NSRange)range
{
    [self changeFontTraitsInRange:range withBlock:^KBFontDescriptorSymbolicTraits(KBFontDescriptorSymbolicTraits currentTraits, NSRange enumeratedRange)
     {
        KBFontDescriptorSymbolicTraits flag = NSFontDescriptorTraitBold;
         return isBold ? currentTraits | flag : currentTraits & ~flag;
     }];
}

- (void)setFontItalics:(BOOL)isItalics
{
    [self setFontItalics:isItalics range:NSMakeRange(0, self.length)];
}

// TODO: Check out the effect of the NSObliquenessAttributeName attribute
//       to see if we can also fake italics fonts by increasing the font skew
- (void)setFontItalics:(BOOL)isItalics range:(NSRange)range
{
    [self changeFontTraitsInRange:range withBlock:^KBFontDescriptorSymbolicTraits(KBFontDescriptorSymbolicTraits currentTraits, NSRange enumeratedRange)
     {
        KBFontDescriptorSymbolicTraits flag = NSFontDescriptorTraitItalic;
         return isItalics ? currentTraits | flag : currentTraits & ~flag;
     }];
}

/******************************************************************************/
#pragma mark - Link

// TODO: Check if setting an URL also changes the text color and underline
//       attributes. I don't believe it does, but either way, document it.
- (void)setURL:(NSURL*)linkURL range:(NSRange)range
{
    [self removeAttribute:NSLinkAttributeName range:range]; // Work around for Apple leak
    if (linkURL)
    {
        [self addAttribute:NSLinkAttributeName value:(id)linkURL range:range];
    }
}

/******************************************************************************/
#pragma mark - Character Spacing

- (void)setCharacterSpacing:(CGFloat)chracterSpacing
{
	[self setCharacterSpacing:chracterSpacing range:NSMakeRange(0,self.length)];
}
- (void)setCharacterSpacing:(CGFloat)characterSpacing range:(NSRange)range
{
    [self addAttribute:NSKernAttributeName value:@(characterSpacing) range:range];
}

/******************************************************************************/
#pragma mark - Subscript and Superscript

- (void)setBaselineOffset:(CGFloat)offset
{
    [self setBaselineOffset:offset range:NSMakeRange(0, self.length)];
}

- (void)setBaselineOffset:(CGFloat)offset range:(NSRange)range
{
    [self removeAttribute:NSBaselineOffsetAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:range];
}

- (void)setSuperscriptForRange:(NSRange)range
{
    KBFont* font = [self attribute:NSFontAttributeName atIndex:range.location effectiveRange:NULL];
    CGFloat offset = + font.pointSize / 2;
    [self setBaselineOffset:offset range:range];
}

- (void)setSubscriptForRange:(NSRange)range
{
    KBFont* font = [self attribute:NSFontAttributeName atIndex:range.location effectiveRange:NULL];
    CGFloat offset = - font.pointSize / 2;
    [self setBaselineOffset:offset range:range];
}

/******************************************************************************/
#pragma mark - Paragraph Style

- (void)setTextAlignment:(NSTextAlignment)alignment
{
	[self setTextAlignment:alignment range:NSMakeRange(0,self.length)];
}

- (void)setTextAlignment:(NSTextAlignment)alignment range:(NSRange)range
{
    [self changeParagraphStylesInRange:range withBlock:^(NSMutableParagraphStyle *paragraphStyle, NSRange enumeratedRange) {
        paragraphStyle.alignment = alignment;
    }];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    [self setLineBreakMode:lineBreakMode range:NSMakeRange(0,self.length)];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range
{
    [self changeParagraphStylesInRange:range withBlock:^(NSMutableParagraphStyle *paragraphStyle, NSRange enumeratedRange) {
        paragraphStyle.lineBreakMode = lineBreakMode;
    }];
}


- (void)changeParagraphStylesWithBlock:(void(^)(NSMutableParagraphStyle*, NSRange))block
{
    [self changeParagraphStylesInRange:NSMakeRange(0,self.length) withBlock:block];
}

- (void)changeParagraphStylesInRange:(NSRange)range withBlock:(void(^)(NSMutableParagraphStyle*, NSRange))block
{
    NSParameterAssert(block != nil);
    [self beginEditing];
    [self enumerateParagraphStylesInRange:range
                         includeUndefined:YES
                               usingBlock:^(id style, NSRange aRange, BOOL *stop)
    {
        if (!style) style = [NSParagraphStyle defaultParagraphStyle];
        NSMutableParagraphStyle* newStyle = [style mutableCopy];
        block(newStyle, aRange);
        [self setParagraphStyle:newStyle range:aRange];
    }];
    [self endEditing];
}

- (void)setParagraphStyle:(NSParagraphStyle *)style
{
    [self setParagraphStyle:style range:NSMakeRange(0,self.length)];
}

// TODO: Check the behavior when applying a paragraph style only to some
//       characters in the middle of an actual paragraph.
- (void)setParagraphStyle:(NSParagraphStyle*)style range:(NSRange)range
{
    [self removeAttribute:NSParagraphStyleAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:NSParagraphStyleAttributeName value:(id)style range:range];
}

@end
