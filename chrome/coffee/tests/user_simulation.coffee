# This file is part of 1clickBOM.
#
# 1clickBOM is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License version 3
# as published by the Free Software Foundation.
#
# 1clickBOM is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with 1clickBOM.  If not, see <http://www.gnu.org/licenses/>.

window.test_bom  = get_local("data/big_example.tsv", json=false)

window.test_one = (country="HK") ->
    QUnit.test "User Sim " + country, () ->
        expect(3)
        stop()
        chrome.storage.local.remove "bom", () ->
            chrome.storage.local.set {country: country}, () ->
                console.log("Test: " + country)
                chrome.runtime.getBackgroundPage (bkgd_page) ->
                    if bkgd_page?
                        bkgd_page.bom_manager.addToBOM window.test_bom, () ->
                            bkgd_page.bom_manager.fillCarts (result) ->
                                deepEqual(result.success, true)
                                deepEqual(result.fails, [])
                                bkgd_page.bom_manager.emptyCarts (result) ->
                                    deepEqual(result.success, true)
                                    start()
window.test_one("HK")
window.test_one("AU")
