/*
 
 CEThemeManager.h
 
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

#import "CESettingFileManager.h"
@import AppKit.NSColor;


// extension for theme file
extern NSString *_Nonnull const CEThemeExtension;

// notifications
extern NSString *_Nonnull const CEThemeListDidUpdateNotification;
extern NSString *_Nonnull const CEThemeDidUpdateNotification;


@class CETheme;


@interface CEThemeManager : CESettingFileManager

// readonly
@property (readonly, nonatomic, nonnull, copy) NSArray<NSString *> *themeNames;


// singleton
+ (nonnull CEThemeManager *)sharedManager;


// public methods
- (nullable CETheme *)themeWithName:(nonnull NSString *)themeName;

/// Theme dict in which objects are property list ready.
- (nullable NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, id> *> *)archivedThemeWithName:(nonnull NSString *)themeName isBundled:(nullable BOOL *)isBundled;

// manage themes
- (BOOL)saveTheme:(nonnull NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)theme name:(nonnull NSString *)themeName completionHandler:(nullable void (^)(NSError *_Nullable error))completionHandler;
- (BOOL)renameThemeWithName:(nonnull NSString *)themeName toName:(nonnull NSString *)newThemeName error:(NSError * _Nullable __autoreleasing * _Nullable)outError;
- (BOOL)duplicateThemeWithName:(nonnull NSString *)themeName error:(NSError * _Nullable __autoreleasing * _Nullable)outError;
- (BOOL)importThemeWithFileURL:(nonnull NSURL *)URL replace:(BOOL)doReplace error:(NSError * _Nullable __autoreleasing * _Nullable)outError;
- (BOOL)createUntitledThemeWithCompletionHandler:(nullable void (^)(NSString *_Nonnull themeName, NSError *_Nullable error))completionHandler;

@end



// Category for migration from CotEditor 1.x to 2.0. (2014-10)
// It can be removed when the most of users have been already migrated in the future.
@interface CEThemeManager (Migration)

- (BOOL)migrateTheme;

@end
