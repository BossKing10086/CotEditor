/*
 
 CETheme.m
 
 CotEditor
 http://coteditor.com
 
 Created by 1024jp on 2014-04-12.

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

#import "CETheme.h"
#import "CEThemeDictionaryKeys.h"
#import "NSColor+WFColorCode.h"


@interface CETheme ()

/// name of the theme
@property (readwrite, nonatomic, nonnull, copy) NSString *name;


// basic colors
@property (readwrite, nonatomic, nonnull) NSColor *textColor;
@property (readwrite, nonatomic, nonnull) NSColor *backgroundColor;
@property (readwrite, nonatomic, nonnull) NSColor *invisiblesColor;
@property (readwrite, nonatomic, nonnull) NSColor *selectionColor;
@property (readwrite, nonatomic, nonnull) NSColor *insertionPointColor;
@property (readwrite, nonatomic, nonnull) NSColor *lineHighLightColor;

// syntax colors
@property (readwrite, nonatomic, nonnull) NSColor *keywordsColor;
@property (readwrite, nonatomic, nonnull) NSColor *commandsColor;
@property (readwrite, nonatomic, nonnull) NSColor *typesColor;
@property (readwrite, nonatomic, nonnull) NSColor *attributesColor;
@property (readwrite, nonatomic, nonnull) NSColor *variablesColor;
@property (readwrite, nonatomic, nonnull) NSColor *valuesColor;
@property (readwrite, nonatomic, nonnull) NSColor *numbersColor;
@property (readwrite, nonatomic, nonnull) NSColor *stringsColor;
@property (readwrite, nonatomic, nonnull) NSColor *charactersColor;
@property (readwrite, nonatomic, nonnull) NSColor *commentsColor;

/// Is background color dark?
@property (readwrite, nonatomic, getter=isDarkTheme) BOOL darkTheme;

/// Is the source theme dict valid?
@property (readwrite, nonatomic, getter=isValid) BOOL valid;

// other options
@property (nonatomic) BOOL usesSystemSelectionColor;

@end




#pragma mark -

@implementation CETheme

#pragma mark Superclass Methods

//------------------------------------------------------
/// disable superclass's designated initializer
- (nullable instancetype)init
//------------------------------------------------------
{
    @throw nil;
}



#pragma mark Public Methods

//------------------------------------------------------
/// convenience constractor
+ (nullable instancetype)themeWithDictinonary:(NSDictionary<NSString *, NSDictionary *> *)themeDict name:(nonnull NSString *)themeName
//------------------------------------------------------
{
    return [[self alloc] initWithDictinonary:themeDict name:themeName];
}


//------------------------------------------------------
/// designated initializer
- (nullable instancetype)initWithDictinonary:(NSDictionary<NSString *, NSDictionary *> *)themeDict name:(nonnull NSString *)themeName
//------------------------------------------------------
{
    if ([themeName length] == 0) { return nil; }
    
    self = [super init];
    if (self) {
        NSMutableDictionary<NSString *, NSColor *> *colorDict = [NSMutableDictionary dictionary];
        
        // カラーを解凍
        _valid = YES;
        for (NSString *key in [[self class] colorKeys]) {
            NSString *colorCode = themeDict[key][CEThemeColorKey];
            
            WFColorCodeType type = WFColorCodeInvalid;
            NSColor *color;
            if (colorCode) {
                color = [NSColor colorWithColorCode:colorCode codeType:&type];
            }
            
            if (!color || !(type == WFColorCodeHex || type == WFColorCodeShortHex)) {
                color = [NSColor grayColor];  // color for invalid color code
                _valid = NO;
            }
            colorDict[key] = color;
        }
        
        // プロパティをセット
        _name = themeName;
        
        _textColor = colorDict[CEThemeTextKey];
        _backgroundColor = colorDict[CEThemeBackgroundKey];
        _invisiblesColor = colorDict[CEThemeInvisiblesKey];
        _selectionColor = colorDict[CEThemeSelectionKey];
        _insertionPointColor = colorDict[CEThemeInsertionPointKey];
        _lineHighLightColor = colorDict[CEThemeLineHighlightKey];
        _keywordsColor = colorDict[CEThemeKeywordsKey];
        _commandsColor = colorDict[CEThemeCommandsKey];
        _typesColor = colorDict[CEThemeTypesKey];
        _attributesColor = colorDict[CEThemeAttributesKey];
        _variablesColor = colorDict[CEThemeVariablesKey];
        _valuesColor = colorDict[CEThemeValuesKey];
        _numbersColor = colorDict[CEThemeNumbersKey];
        _stringsColor = colorDict[CEThemeStringsKey];
        _charactersColor = colorDict[CEThemeCharactersKey];
        _commentsColor = colorDict[CEThemeCommentsKey];
        
        _usesSystemSelectionColor = [themeDict[CEThemeSelectionKey][CEThemeUsesSystemSettingKey] boolValue];
        
        // 安全に値が取り出せるようにカラースペースを統一する
        NSColor *textColor = [_textColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        NSColor *backgroundColor = [_backgroundColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        
        // 背景が暗いかを判定して属性として保持
        _darkTheme = ([backgroundColor brightnessComponent] < [textColor brightnessComponent]);
    }
    return self;
}


//------------------------------------------------------
/// 選択範囲のハイライトカラーを返す
- (nonnull NSColor *)selectionColor
//------------------------------------------------------
{
    // システム環境設定の設定を使う場合はここで再定義する
    if ([self usesSystemSelectionColor]) {
        return [NSColor selectedTextBackgroundColor];
    }
    return _selectionColor;
}


//------------------------------------------------------
/// color for syntax type defined in theme
- (nullable NSColor *)syntaxColorForType:(nonnull NSString *)syntaxType
//------------------------------------------------------
{
    if ([syntaxType isEqualToString:CEThemeKeywordsKey]) {
        return [self keywordsColor];
    } else if ([syntaxType isEqualToString:CEThemeCommandsKey]) {
        return [self commandsColor];
    } else if ([syntaxType isEqualToString:CEThemeTypesKey]) {
        return [self typesColor];
    } else if ([syntaxType isEqualToString:CEThemeAttributesKey]) {
        return [self attributesColor];
    } else if ([syntaxType isEqualToString:CEThemeVariablesKey]) {
        return [self variablesColor];
    } else if ([syntaxType isEqualToString:CEThemeValuesKey]) {
        return [self valuesColor];
    } else if ([syntaxType isEqualToString:CEThemeNumbersKey]) {
        return [self numbersColor];
    } else if ([syntaxType isEqualToString:CEThemeStringsKey]) {
        return [self stringsColor];
    } else if ([syntaxType isEqualToString:CEThemeCharactersKey]) {
        return [self charactersColor];
    } else if ([syntaxType isEqualToString:CEThemeCommentsKey]) {
        return [self commentsColor];
    }
    
    return nil;
}



#pragma mark Private Methods

//------------------------------------------------------
/// テーマファイルで色が格納されているキー
+ (nonnull NSArray<NSString *> *)colorKeys
//------------------------------------------------------
{
    return @[CEThemeTextKey,
             CEThemeBackgroundKey,
             CEThemeInvisiblesKey,
             CEThemeSelectionKey,
             CEThemeInsertionPointKey,
             CEThemeLineHighlightKey,
             CEThemeKeywordsKey,
             CEThemeCommandsKey,
             CEThemeTypesKey,
             CEThemeAttributesKey,
             CEThemeVariablesKey,
             CEThemeValuesKey,
             CEThemeNumbersKey,
             CEThemeStringsKey,
             CEThemeCharactersKey,
             CEThemeCommentsKey];
}

@end
