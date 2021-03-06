/*
 
 URLExtensionsTests.swift
 Tests
 
 CotEditor
 http://coteditor.com
 
 Created by 1024jp on 2016-06-10.
 
 ------------------------------------------------------------------------------
 
 © 2016 1024jp
 
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

import XCTest

class URLExtensionsTests: XCTestCase {

    func testRelativeURLCreation() {
        let url = NSURL(string: "/foo/bar/file.txt")
        let baseUrl = NSURL(string: "/foo/buz/file.txt")
        
        XCTAssertEqual(url?.pathRelativeToURL(baseUrl), "../bar/file.txt")
        
        XCTAssertNil(url?.pathRelativeToURL(nil))
        XCTAssertNil(url?.pathRelativeToURL(NSURL(string: url!.path!)))
    }

}
