/*
 
 CEEditorViewController.m
 
 CotEditor
 http://coteditor.com
 
 Created by nakamuxu on 2006-03-18.
 
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

#import "CEEditorViewController.h"
#import "CENavigationBarController.h"
#import "CETextView.h"
#import "CESyntaxStyle.h"

#import "CEGoToLineViewController.h"


@interface CEEditorViewController ()

@property (nonatomic, nullable, weak) IBOutlet __kindof NSScrollView *scrollView;


// readonly
@property (readwrite, nullable, nonatomic) IBOutlet CETextView *textView;
@property (readwrite, nullable, nonatomic) IBOutlet CENavigationBarController *navigationBarController;

@end




#pragma mark -

@implementation CEEditorViewController

#pragma mark Superclass Methods

// ------------------------------------------------------
/// clean up
- (void)dealloc
// ------------------------------------------------------
{
    [_textStorage removeLayoutManager:[_textView layoutManager]];
}


// ------------------------------------------------------
/// nib name
- (nullable NSString *)nibName
// ------------------------------------------------------
{
    return @"EditorView";
}


// ------------------------------------------------------
/// setup UI
- (void)viewDidLoad
// ------------------------------------------------------
{
    [super viewDidLoad];
    
    [[self navigationBarController] setTextView:[self textView]];
    
    [self addChildViewController:[self navigationBarController]];
    
    // set textStorage to textView
    [[[self textView] layoutManager] replaceTextStorage:[self textStorage]];
}


// ------------------------------------------------------
/// validate actions
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
// ------------------------------------------------------
{
    if ([menuItem action] == @selector(selectPrevItemOfOutlineMenu:)) {
        return [[self navigationBarController] canSelectPrevItem];
    } else if ([menuItem action] == @selector(selectNextItemOfOutlineMenu:)) {
        return [[self navigationBarController] canSelectNextItem];
    }
    
    return YES;
}



#pragma mark Public Methods

// ------------------------------------------------------
/// 行番号表示設定をセット
- (void)setShowsLineNum:(BOOL)showsLineNum
// ------------------------------------------------------
{
    [[self scrollView] setRulersVisible:showsLineNum];
}


// ------------------------------------------------------
/// ナビゲーションバーを表示／非表示
- (void)setShowsNavigationBar:(BOOL)showsNavigationBar animate:(BOOL)performAnimation;
// ------------------------------------------------------
{
    [[self navigationBarController] setShown:showsNavigationBar animate:performAnimation];
}


// ------------------------------------------------------
/// シンタックススタイルを設定
- (void)applySyntax:(nonnull CESyntaxStyle *)syntaxStyle
// ------------------------------------------------------
{
    [[self textView] setInlineCommentDelimiter:[syntaxStyle inlineCommentDelimiter]];
    [[self textView] setBlockCommentDelimiters:[syntaxStyle blockCommentDelimiters]];
    [[self textView] setSyntaxCompletionWords:[syntaxStyle completionWords]];
    [[self textView] setFirstSyntaxCompletionCharacterSet:[syntaxStyle firstCompletionCharacterSet]];
}



#pragma mark Action Messages

// ------------------------------------------------------
/// show Go To sheet
- (IBAction)gotoLocation:(nullable id)sender
// ------------------------------------------------------
{
    CEGoToLineViewController *viewController = [[CEGoToLineViewController alloc] initWithTextView:[self textView]];
    
    [self presentViewControllerAsSheet:viewController];
}


// ------------------------------------------------------
/// アウトラインメニューの前の項目を選択（メニューバーからのアクションを中継）
- (IBAction)selectPrevItemOfOutlineMenu:(nullable id)sender
// ------------------------------------------------------
{
    [[self navigationBarController] selectPrevItem:sender];
}


// ------------------------------------------------------
/// アウトラインメニューの次の項目を選択（メニューバーからのアクションを中継）
- (IBAction)selectNextItemOfOutlineMenu:(nullable id)sender
// ------------------------------------------------------
{
    [[self navigationBarController] selectNextItem:sender];
}

@end
