/*
 
 CESyntaxEditViewController.m
 
 CotEditor
 http://coteditor.com
 
 Created by 1024jp on 2014-04-03.

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

#import "CESyntaxEditViewController.h"
#import "CESyntaxTermsEditViewController.h"
#import "CESyntaxValidationViewController.h"
#import "CESyntaxManager.h"
#import "CESyntaxDictionaryKeys.h"
#import "Constants.h"


typedef NS_ENUM(NSUInteger, CESyntaxEditViewIndex) {
    KeywordsTab,
    CommandsTab,
    TypesTab,
    AttributesTab,
    VariablesTab,
    ValuesTab,
    NumbersTab,
    StringsTab,
    CharactersTab,
    CommentsTab,
    
    OutlineTab     = 11,
    CompletionTab  = 12,
    FileMappingTab = 13,
    
    StyleInfoTab   = 15,
    ValidationTab  = 16,
};


@interface CESyntaxEditViewController () <NSTextFieldDelegate, NSTableViewDelegate>

@property (nonatomic, nonnull) NSMutableDictionary<NSString *, id> *style;
@property (nonatomic) CESyntaxEditSheetMode mode;
@property (nonatomic, nonnull, copy) NSString *originalStyleName;   // シートを生成した際に指定したスタイル名
@property (nonatomic, nullable, copy) NSString *message;
@property (nonatomic, getter=isStyleNameValid) BOOL styleNameValid;
@property (nonatomic, getter=isBundledStyle) BOOL bundledStyle;

@property (nonatomic, nullable, copy) NSArray<__kindof NSViewController *> *viewControllers;

@property (nonatomic, nullable, weak) IBOutlet NSBox *box;
@property (nonatomic, nullable, weak) IBOutlet NSTableView *menuTableView;
@property (nonatomic, nullable, weak) IBOutlet NSTextField *styleNameField;
@property (nonatomic, nullable, weak) IBOutlet NSButton *restoreButton;

@end




#pragma mark -

@implementation CESyntaxEditViewController

#pragma mark Superclass Methods

// ------------------------------------------------------
/// initialize
- (nullable instancetype)initWithStyle:(nonnull NSString *)styleName mode:(CESyntaxEditSheetMode)mode
// ------------------------------------------------------
{
    self = [super init];
    if (self) {
        CESyntaxManager *syntaxManager = [CESyntaxManager sharedManager];
        NSString *name;
        NSDictionary<NSString *, id> *style;
        
        switch (mode) {
            case CECopySyntaxEdit:
                name = [syntaxManager copiedSettingName:styleName];
                style = [syntaxManager styleDictionaryWithStyleName:styleName];
                break;
                
            case CENewSyntaxEdit:
                name = @"";
                style = [syntaxManager emptyStyleDictionary];
                break;
                
            case CESyntaxEdit:
                name = styleName;
                style = [syntaxManager styleDictionaryWithStyleName:styleName];
                break;
        }
        if (!name) { return nil; }
        
        _mode = mode;
        _originalStyleName = name;
        _style = [style mutableCopy];
        _styleNameValid = YES;
        _bundledStyle = [syntaxManager isBundledSetting:name cutomized:nil];
        
        if (_bundledStyle) {
            _message = NSLocalizedString(@"Bundled styles can’t be renamed.", nil);
        }
    }
    return self;
}


// ------------------------------------------------------
/// nib name
- (nullable NSString *)nibName
// ------------------------------------------------------
{
    return @"SyntaxEditView";
}


// ------------------------------------------------------
/// setup UI
- (void)viewDidLoad
// ------------------------------------------------------
{
    [super viewDidLoad];
    
    // setup style name field and restore button
    [[self styleNameField] setStringValue:[self originalStyleName]];
    
    if ([self isBundledStyle]) {
        BOOL isEqual = [[CESyntaxManager sharedManager] isEqualToBundledStyle:[self style]
                                                                         name:[self originalStyleName]];
        
        [[self styleNameField] setDrawsBackground:NO];
        [[self styleNameField] setBezeled:NO];
        [[self styleNameField] setSelectable:NO];
        [[self styleNameField] setEditable:NO];
        [[self styleNameField] setBordered:YES];
        [[self restoreButton] setEnabled:!isEqual];
        
    } else {
        [[self restoreButton] setEnabled:NO];
    }
    
    // setup views
    NSMutableArray<id> *viewControllers = [NSMutableArray array];
    
    // setup keywords views (until Characters tab)
    for (NSUInteger i = 0; i <= CharactersTab; i++) {
        NSString *key = kAllSyntaxKeys[i];
        viewControllers[i] = [[CESyntaxTermsEditViewController alloc] initWithStynaxType:key];
    }
    viewControllers[CommentsTab] = [[NSViewController alloc] initWithNibName:@"SyntaxCommentsEditView" bundle:nil];
    
    [viewControllers addObject:[NSNull null]];  // separator
    
    viewControllers[OutlineTab] = [[NSViewController alloc] initWithNibName:@"SyntaxOutlineEditView" bundle:nil];
    viewControllers[CompletionTab] = [[NSViewController alloc] initWithNibName:@"SyntaxCompletionsEditView" bundle:nil];
    viewControllers[FileMappingTab] = [[NSViewController alloc] initWithNibName:@"SyntaxFileMappingEditView" bundle:nil];
    
    [viewControllers addObject:[NSNull null]];  // separator
    
    viewControllers[StyleInfoTab] = [[NSViewController alloc] initWithNibName:@"SyntaxInfoEditView" bundle:nil];
    viewControllers[ValidationTab] = [[CESyntaxValidationViewController alloc] init];
    
    for (__kindof NSViewController *viewController in viewControllers) {
        if ([viewController isKindOfClass:[NSNull class]]) { continue; }
        [viewController setRepresentedObject:[self style]];
    }
    
    [self setViewControllers:[viewControllers copy]];
    [self swapViewWithIndex:0];
}



#pragma mark Delegate

//=======================================================
// NSTextFieldDelegate  < styleNameField
//=======================================================

// ------------------------------------------------------
/// スタイル名が変更された
- (void)controlTextDidChange:(nonnull NSNotification *)notification
// ------------------------------------------------------
{
    // 入力されたスタイル名の検証
    if ([notification object] == [self styleNameField]) {
        NSString *styleName = [[self styleNameField] stringValue];
        styleName = [styleName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self validateStyleName:styleName];
    }
}


//=======================================================
// NSTableViewDelegate  < menuTableView
//=======================================================

// ------------------------------------------------------
/// tableView の選択が変更された
- (void)tableViewSelectionDidChange:(nonnull NSNotification *)notification
// ------------------------------------------------------
{
    NSTableView *tableView = [notification object];
    NSInteger row = [tableView selectedRow];
    
    // switch view
    [self swapViewWithIndex:row];
}


// ------------------------------------------------------
/// 行を選択するべきかを返す
- (BOOL)tableView:(nonnull NSTableView *)tableView shouldSelectRow:(NSInteger)row
// ------------------------------------------------------
{
    // セパレータは選択不可
    return ![[self menuTitles][row] isEqualToString:CESeparatorString];
}



#pragma mark Action Messages

// ------------------------------------------------------
/// スタイルの内容を出荷時設定に戻す
- (IBAction)setToFactoryDefaults:(nullable id)sender
// ------------------------------------------------------
{
    NSMutableDictionary<NSString *, id> *style = [[[CESyntaxManager sharedManager] bundledStyleDictionaryWithStyleName:[self originalStyleName]] mutableCopy];
    
    if (!style) { return; }
    
    // フォーカスを移しておく
    [[sender window] makeFirstResponder:[sender window]];
    // 内容をセット
    [[self style] setDictionary:style];
    // デフォルト設定に戻すボタンを無効化
    [[self restoreButton] setEnabled:NO];
}


// ------------------------------------------------------
/// jump to style's destribution URL
- (IBAction)jumpToURL:(nullable id)sender
// ------------------------------------------------------
{
    NSURL *URL = [NSURL URLWithString:[self style][CEMetadataKey][CEDistributionURLKey]];
    
    if (!URL) {
        NSBeep();
        return;
    }
    
    [[NSWorkspace sharedWorkspace] openURL:URL];
}


// ------------------------------------------------------
/// カラーシンタックス編集シートの OK ボタンが押された
- (IBAction)saveEdit:(nullable id)sender
// ------------------------------------------------------
{
    // フォーカスを移して入力中の値を確定
    [[sender window] makeFirstResponder:sender];
    
    // style名から先頭または末尾のスペース／タブ／改行を排除
    NSString *styleName = [[[self styleNameField] stringValue]
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [[self styleNameField] setStringValue:styleName];
    
    // style名のチェック
    if (![self validateStyleName:styleName]) {
        [[[self view] window] makeFirstResponder:[self styleNameField]];
        NSBeep();
        return;
    }
    
    // エラー未チェックかつエラーがあれば、表示（エラーを表示していてOKボタンを押下したら、そのまま確定）
    CESyntaxValidationViewController *validationController = [self viewControllers][ValidationTab];
    if (![validationController didValidate] && ([validationController validate] > 0)) {
        // 「構文要素チェック」を選択
        // （selectItemAtIndex: だとバインディングが実行されないので、メニューを取得して選択している）
        NSBeep();
        [[self menuTableView] selectRowIndexes:[NSIndexSet indexSetWithIndex:ValidationTab] byExtendingSelection:NO];
        return;
    }
    
    [[CESyntaxManager sharedManager] saveStyle:[self style]
                                          name:styleName
                                       oldName:[self originalStyleName]];
    
    [self dismissController:sender];
}


// ------------------------------------------------------
/// カラーシンタックス編集シートの Cancel ボタンが押された
- (IBAction)cancelEdit:(nullable id)sender
// ------------------------------------------------------
{
    [self dismissController:sender];
}



#pragma mark Private Mthods

// ------------------------------------------------------
/// メニュー項目を返す
- (nonnull NSArray<NSString *> *)menuTitles
// ------------------------------------------------------
{
    return @[NSLocalizedString(@"Keywords", nil),
             NSLocalizedString(@"Commands", nil),
             NSLocalizedString(@"Types", nil),
             NSLocalizedString(@"Attributes", nil),
             NSLocalizedString(@"Variables", nil),
             NSLocalizedString(@"Values", nil),
             NSLocalizedString(@"Numbers", nil),
             NSLocalizedString(@"Strings", nil),
             NSLocalizedString(@"Characters", nil),
             NSLocalizedString(@"Comments", nil),
             CESeparatorString,
             NSLocalizedString(@"Outline Menu", nil),
             NSLocalizedString(@"Completion List", nil),
             NSLocalizedString(@"File Mapping", nil),
             CESeparatorString,
             NSLocalizedString(@"Style Info", nil),
             NSLocalizedString(@"Syntax Validation", nil)];
}


// ------------------------------------------------------
/// ビューを切り替える
- (void)swapViewWithIndex:(CESyntaxEditViewIndex)index
// ------------------------------------------------------
{
    // finish current edit
    [[[self view] window] makeFirstResponder:[self menuTableView]];
    
    // swap view
    [[self box] setContentView:[[self viewControllers][index] view]];
}


// ------------------------------------------------------
/// validate passed-in style name and return if valid
- (BOOL)validateStyleName:(nonnull NSString *)styleName;
// ------------------------------------------------------
{
    if (([self mode] == CESyntaxEdit) && [self isBundledStyle]) {
        return YES;
    }
    
    NSError *error = nil;
    
    if (!(([self mode] == CESyntaxEdit) &&
          ([styleName caseInsensitiveCompare:[self originalStyleName]] == NSOrderedSame)))
    {
        [[CESyntaxManager sharedManager] validateSettingName:styleName originalName:[self originalStyleName] error:&error];
    }
    
    [self setStyleNameValid:(!error)];
    [self setMessage:error ? [NSString stringWithFormat:@"⚠️ %@ %@", [error localizedDescription], [error localizedRecoverySuggestion]] : nil];
    
    return [self isStyleNameValid];
}

@end
