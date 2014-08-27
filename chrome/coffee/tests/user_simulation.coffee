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

@test_bom  = get_local("data/big_example.tsv", json=false)

@test_one = (country="CN") ->
    QUnit.test "User Sim " + country, () ->
        expect(3)
        stop()
        chrome.storage.local.set {country: country}, () ->
            console.log("Test, " + country + " 1")
            chrome.storage.local.remove "bom", () ->
                console.log("Test, " + country + " 2")
                (new BomManager).addToBOM test_bom, (that) ->
                    console.log("Test, " + country + " 3")
                    that.emptyCarts (result) ->
                        console.log("Test, " + country + " 4")
                        deepEqual(result.success, true)
                        that.fillCarts (result) ->
                            console.log("Test, " + country + " 5")
                            deepEqual(result.success, true)
                            deepEqual(result.fails, [])
                            start()
test_one()

