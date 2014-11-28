# The contents of this file are subject to the Common Public Attribution
# License Version 1.0 (the “License”); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
# License Version 1.1 but Sections 14 and 15 have been added to cover use of
# software over a computer network and provide for limited attribution for the
# Original Developer. In addition, Exhibit A has been modified to be consistent
# with Exhibit B.
#
# Software distributed under the License is distributed on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations under
# the License.
#
# The Original Code is 1clickBOM.
#
# The Original Developer is the Initial Developer. The Original Developer of
# the Original Code is Kaspar Emanuel.

window.test_bom  = get_local("data/big_example.tsv", json=false)

window.test_one = (country="HK") ->
    QUnit.test "User Sim " + country, () ->
        expect(3)
        stop()
        browser.storageRemove "bom", () ->
            browser.storageSet {country: country}, () ->
                console.log("Test: " + country)
                browser.getBackgroundPage (bkgd_page) ->
                    if bkgd_page?
                        setTimeout () ->
                            bkgd_page.bom_manager.addToBOM window.test_bom, () ->
                                bkgd_page.bom_manager.fillCarts (result) ->
                                    deepEqual(result.success, true)
                                    deepEqual(result.fails, [])
                                    bkgd_page.bom_manager.emptyCarts (result) ->
                                        deepEqual(result.success, true)
                                        start()
                        , 1000
for c in [ "AU", "MY", "PH", "TW", "NZ", "KR"
         , "CN", "TH", "IN", "HK", "SG"]
    window.test_one(c)
