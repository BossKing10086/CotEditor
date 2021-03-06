/*
 
 CEATSTypesetter.m
 
 CotEditor
 http://coteditor.com
 
 Created by nakamuxu on 2005-12-08.

 ------------------------------------------------------------------------------
 
 © 2004-2007 nakamuxu
 © 2014-2016 1024jp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

#import "CEATSTypesetter.h"
#import "CELayoutManager.h"


@implementation CEATSTypesetter

#pragma mark ATS Typesetter Methods

// ------------------------------------------------------
/// adjust vertical position to keep line height even with composed font
- (void)willSetLineFragmentRect:(nonnull NSRectPointer)lineRect forGlyphRange:(NSRange)glyphRange usedRect:(nonnull NSRectPointer)usedRect baselineOffset:(nonnull CGFloat *)baselineOffset
// ------------------------------------------------------
{
    // 複合フォントで行の高さがばらつくのを防止する
    //   -> CELayoutManager の関連メソッドをオーバーライドしてあれば、このメソッドをオーバーライドしなくても
    //      通常の入力では行間が一定になるが、フォントや行間を変更したときに適正に描画されない。
    //   -> CETextView で、NSParagraphStyle の lineHeightMultiple を設定しても行間は制御できるが、
    //      「文書の1文字目に1バイト文字（または2バイト文字）を入力してある状態で先頭に2バイト文字（または1バイト文字）を
    //      挿入すると行間がズレる」問題が生じる。
    
    CELayoutManager *manager = (CELayoutManager *)[self layoutManager];
    
    lineRect->size.height = [manager lineHeight];
    usedRect->size.height = [manager lineHeight];
    *baselineOffset = [manager defaultBaselineOffset];
}


// ------------------------------------------------------
/// customize behavior by control glyph
- (NSTypesetterControlCharacterAction)actionForControlCharacterAtIndex:(NSUInteger)charIndex
// ------------------------------------------------------
{
    NSTypesetterControlCharacterAction result = [super actionForControlCharacterAtIndex:charIndex];
    
    if (result & NSTypesetterZeroAdvancementAction) {
        NSString *string = [[self attributedString] string];
        BOOL isLowSurrogate = (CFStringIsSurrogateLowCharacter([string characterAtIndex:charIndex]) &&
                               ((charIndex > 0) && CFStringIsSurrogateHighCharacter([string characterAtIndex:charIndex - 1])));
        if (!isLowSurrogate) {
            return NSTypesetterWhitespaceAction;  // -> Then, the glyph width can be modified on `boundingBoxForControlGlyphAtIndex:...`.
        }
    }
    
    return result;
}


// ------------------------------------------------------
/// return bounding box for control glyph
- (NSRect)boundingBoxForControlGlyphAtIndex:(NSUInteger)glyphIndex forTextContainer:(nonnull NSTextContainer *)textContainer proposedLineFragment:(NSRect)proposedRect glyphPosition:(NSPoint)glyphPosition characterIndex:(NSUInteger)charIndex
// ------------------------------------------------------
{
    CELayoutManager *manager = (CELayoutManager *)[self layoutManager];
    if (![manager showsOtherInvisibles] || ![manager showsInvisibles]) {
        // DON'T invoke super method here. If invoked, it can not continue drawing remaining lines any more on Mountain Lion (and possible other versions except El Capitan).
        // Just passing zero rect is enough if you dont need to draw.
        return NSZeroRect;
    }
    
    // make blank space to draw a replacement character in CELayoutManager later.
    NSFont *textFont = [manager textFont];
    NSFont *invisibleFont = [NSFont fontWithName:@"Lucida Grande" size:[textFont pointSize]] ?: textFont;  // use current text font for fallback
    NSGlyph replacementGlyph = [invisibleFont glyphWithName:@"replacement"];  // U+FFFD
    NSRect replacementGlyphBounding = [invisibleFont boundingRectForGlyph:replacementGlyph];
    proposedRect.size.width = replacementGlyphBounding.size.width;
    
    return proposedRect;
}


// ------------------------------------------------------
/// avoid soft warpping just after an indent
- (BOOL)shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex
// ------------------------------------------------------
{
    if (charIndex == 0) { return YES; }
    
    // check if the character is the first non-whitespace character after indent
    NSString *string = [[self attributedString] string];
    for (NSInteger index = charIndex - 1; index >= 0; index--) {
        unichar character = [string characterAtIndex:index];
        
        if (character == '\n') { return NO; }  // the line ended before hitting to any indent characters
        if (character != ' ' && character != '\t') { return YES; }  // hit to non-indent character
    }
    
    return NO;  // didn't hit to line-break (= first line)
}

@end
