/*
 
 Constants.m
 
 CotEditor
 http://coteditor.com
 
 Created by nakamuxu on 2004-12-13.
 
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

#import "Constants.h"


#pragma mark General

// ------------------------------------------------------
// General
// ------------------------------------------------------

// separator
NSString *_Nonnull const CESeparatorString = @"-";

// Exported UTI
NSString *_Nonnull const CEUTTypeTheme = @"com.coteditor.CotEditor.theme";

// Metadata dict keys for themes and syntax styles
NSString *_Nonnull const CEMetadataKey = @"metadata";
NSString *_Nonnull const CEAuthorKey = @"author";
NSString *_Nonnull const CEDistributionURLKey = @"distributionURL";
NSString *_Nonnull const CELicenseKey = @"license";
NSString *_Nonnull const CEDescriptionKey = @"description";


// Help anchors
NSString *_Nonnull const kHelpAnchors[] = {
    @"releasenotes",
    @"pref_general",
    @"pref_window",
    @"pref_appearance",
    @"pref_edit",
    @"pref_format",  // 5
    @"pref_filedrop",
    @"pref_keybindings",
    @"pref_print",
    @"whats_new",
    @"specification_changes",  // 10
    @"howto_customize_scriptmenu",
    @"about_applescript",
    @"about_unixscript",
    @"pref_integration",
    @"about_file_mapping",  // 15
    @"about_cot",
    
    @"about_syntaxstyle",
    @"about_comment_settings",
    @"about_outlinemenu_settings",
    @"about_complist_settings",  // 20
    @"about_file_mapping",
    @"about_styleinfo_settings",
};


// Convenient functions
/// compare CGFloats
BOOL CEIsAlmostEqualCGFloats(CGFloat float1, CGFloat float2) {
    const double ACCURACY = 5;
    return (fabs(float1 - float2) < pow(10, -ACCURACY));
}

/// invoke passed-in block on main thread
void dispatch_sync_on_main_thread(_Nonnull dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            block();
        });
    }
}



#pragma mark File Drop

// ------------------------------------------------------
// File Drop
// ------------------------------------------------------

// keys for dicts in CEDefaultFileDropArrayKey
NSString *_Nonnull const CEFileDropExtensionsKey = @"extensions";
NSString *_Nonnull const CEFileDropFormatStringKey = @"formatString";

// tokens
NSString *_Nonnull const CEFileDropTokenAbsolutePath = @"<<<ABSOLUTE-PATH>>>";
NSString *_Nonnull const CEFileDropTokenRelativePath = @"<<<RELATIVE-PATH>>>";
NSString *_Nonnull const CEFileDropTokenFilename = @"<<<FILENAME>>>";
NSString *_Nonnull const CEFileDropTokenFilenameNosuffix = @"<<<FILENAME-NOSUFFIX>>>";
NSString *_Nonnull const CEFileDropTokenFileextension = @"<<<FILEEXTENSION>>>";
NSString *_Nonnull const CEFileDropTokenFileextensionLower = @"<<<FILEEXTENSION-LOWER>>>";
NSString *_Nonnull const CEFileDropTokenFileextensionUpper = @"<<<FILEEXTENSION-UPPER>>>";
NSString *_Nonnull const CEFileDropTokenDirectory = @"<<<DIRECTORY>>>";
NSString *_Nonnull const CEFileDropTokenImageWidth = @"<<<IMAGEWIDTH>>>";
NSString *_Nonnull const CEFileDropTokenImageHeight = @"<<<IMAGEHEIGHT>>>";



#pragma mark Main Menu

// ------------------------------------------------------
// Main Menu
// ------------------------------------------------------

// Online URLs
NSString *_Nonnull const kWebSiteURL = @"http://coteditor.com";
NSString *_Nonnull const kIssueTrackerURL = @"https://github.com/coteditor/CotEditor/issues";
