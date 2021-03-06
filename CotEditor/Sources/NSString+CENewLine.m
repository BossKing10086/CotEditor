/*
 
 NSString+CENewLine.m
 
 CotEditor
 http://coteditor.com
 
 Created by 1024jp on 2014-11-30.
 
 ------------------------------------------------------------------------------
 
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

#import "NSString+CENewLine.h"


unichar const kNewLineChars[] = {
    NSNewlineCharacter,
    NSCarriageReturnCharacter,
    NSLineSeparatorCharacter,
    NSParagraphSeparatorCharacter
};


@implementation NSString (CENewLine)

#pragma mark Public Methods

// ------------------------------------------------------
/// NSString form for new line character
+ (nonnull NSString *)newLineStringWithType:(CENewLineType)type
// ------------------------------------------------------
{
    switch (type) {
        case CENewLineLF:  // NSNewlineCharacter
            return @"\n";
        case CENewLineCR:  // NSCarriageReturnCharacter
            return @"\r";
        case CENewLineCRLF:  // CR+LF
            return @"\r\n";
        case CENewLineLineSeparator:
            return [NSString stringWithFormat:@"%C", (unichar)NSLineSeparatorCharacter];
        case CENewLineParagraphSeparator:
            return [NSString stringWithFormat:@"%C", (unichar)NSParagraphSeparatorCharacter];
        case CENewLineNone:  // 改行なし
        default:
            return @"";
    }
}


// ------------------------------------------------------
/// line ending name to display
+ (nonnull NSString *)newLineNameWithType:(CENewLineType)type
// ------------------------------------------------------
{
    switch (type) {
        case CENewLineLF:
            return @"LF";
        case CENewLineCR:
            return @"CR";
        case CENewLineCRLF:
            return @"CR/LF";
        case CENewLineLineSeparator:
            return @"LS";
        case CENewLineParagraphSeparator:
            return @"PS";
        case CENewLineNone:
            return @"";
    }
}


// ------------------------------------------------------
/// return the first new line charater type
- (CENewLineType)detectNewLineType
// ------------------------------------------------------
{
    if ([self length] == 0) { return CENewLineNone; }
    
    // We don't use [NSCharacterSet newlineCharacterSet] because it contains more characters than we need.
    NSString *newLineSetString = [NSString stringWithCharacters:kNewLineChars
                                                         length:sizeof(kNewLineChars) / sizeof(unichar)];
    NSCharacterSet *newLineSet = [NSCharacterSet characterSetWithCharactersInString:newLineSetString];
    
    NSUInteger location = [self rangeOfCharacterFromSet:newLineSet].location;
    
    if (location == NSNotFound) { return CENewLineNone; }
    
    switch ([self characterAtIndex:location]) {
        case NSNewlineCharacter:
            return CENewLineLF;
            
        case NSCarriageReturnCharacter:
            if (([self length] > location + 1) && ([self characterAtIndex:location + 1] == NSNewlineCharacter)) {
                return CENewLineCRLF;
            }
            return CENewLineCR;
            
        case NSLineSeparatorCharacter:
            return CENewLineLineSeparator;
            
        case NSParagraphSeparatorCharacter:
            return CENewLineParagraphSeparator;
            
        default:
            return CENewLineNone;
    }
}


// ------------------------------------------------------
/// replace all kind of new line characters in the string with the desired new line type.
- (nonnull NSString *)stringByReplacingNewLineCharacersWith:(CENewLineType)type
// ------------------------------------------------------
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\r\\n|[\\n\\r\\u2028\\u2029]"
                                                                           options:0 error:nil];
    
    return [regex stringByReplacingMatchesInString:self
                                           options:0
                                             range:NSMakeRange(0, [self length])
                                      withTemplate:[NSString newLineStringWithType:type]];
}


// ------------------------------------------------------
/// remove all kind of new line characters in string
- (nonnull NSString *)stringByDeletingNewLineCharacters
// ------------------------------------------------------
{
    return [self stringByReplacingNewLineCharacersWith:CENewLineNone];
}


// ------------------------------------------------------
/// convert passed-in range as if line endings are changed from fromType to toType
- (NSRange)convertRange:(NSRange)range fromNewLineType:(CENewLineType)fromType toNewLineType:(CENewLineType)toType
// ------------------------------------------------------
{
    if (fromType == CENewLineNone) {
        fromType = [self detectNewLineType];
    }
    
    if (fromType == toType ||
        (fromType != CENewLineCRLF && toType != CENewLineCRLF))
    {
        return range;
    }
    
    // sanitize for CR/LF
    NSString *tmpLocStr = [self substringToIndex:range.location];
    NSString *tmpLenStr = [self substringWithRange:range];
    NSString *locStr = [tmpLocStr stringByReplacingNewLineCharacersWith:toType];
    NSString *lenStr = [tmpLenStr stringByReplacingNewLineCharacersWith:toType];
    
    return NSMakeRange([locStr length], [lenStr length]);
}

@end
