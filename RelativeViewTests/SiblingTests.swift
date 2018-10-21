//
//  SiblingTests.swift
//  RelativeViewTests
//
//  Created by Jae Yeum on 9/17/18.
//  Copyright © 2018 RelativeView - Jae Yeum. All rights reserved.
//

import XCTest
@testable import RelativeView

class SiblingTests: XCTestCase {

    /// Tests that **isRelativeSibling(of view:)** works properly.
    func testIsRelativeSiblingOfView() {
        // Let's set up a sibling relationship under a view.
        let view: UIView = UIView()
        let foo: UIButton = UIButton()
        view.addSubview(foo)
        let bar: UILabel = UILabel()
        view.addSubview(bar)
        
        // Verify our sibling relationship is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(view.superview)
        XCTAssertEqual(2, view.subviews.count)
        XCTAssertTrue(view.subviews[0] === foo)
        XCTAssertTrue(view.subviews[1] === bar)
        XCTAssertTrue(view === foo.superview)
        XCTAssertTrue(foo.subviews.isEmpty)
        XCTAssertTrue(view === bar.superview)
        XCTAssertTrue(bar.subviews.isEmpty)
        
        // Let's set up a separate sibling relationship under another view.
        let anotherView: UIView = UIView()
        let anotherFoo: UIButton = UIButton()
        anotherView.addSubview(anotherFoo)
        let anotherBar: UILabel = UILabel()
        anotherView.addSubview(anotherBar)
        
        // Verify the separate sibling relationship is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(anotherView.superview)
        XCTAssertEqual(2, anotherView.subviews.count)
        XCTAssertTrue(anotherView.subviews[0] === anotherFoo)
        XCTAssertTrue(anotherView.subviews[1] === anotherBar)
        XCTAssertTrue(anotherView === anotherFoo.superview)
        XCTAssertTrue(anotherFoo.subviews.isEmpty)
        XCTAssertTrue(anotherView === anotherBar.superview)
        XCTAssertTrue(anotherBar.subviews.isEmpty)
        
        // First let's test the negative test cases.
        
        // A sibling relationship cannot exist between a view and itself.
        XCTAssertFalse(foo.isRelativeSibling(of: foo))
        XCTAssertFalse(bar.isRelativeSibling(of: bar))
        
        // Now let's check the permutations for a superview being nil.
        
        // A sibling relationship cannot exist between potential siblings where either have a nil superview (which is really just saying they must share
        // the same superview) or both have a nil superview. This covers three of the four possible permutations.
        XCTAssertFalse(UIView().isRelativeSibling(of: foo))
        XCTAssertFalse(foo.isRelativeSibling(of: UIView()))
        XCTAssertFalse(UIView().isRelativeSibling(of: UIView()))
        
        // A sibling relationship cannot exist between potential siblings that have different non-nil superviews, this covers the final of the four
        // possible permutations.
        XCTAssertFalse(foo.isRelativeSibling(of: anotherFoo))
        XCTAssertFalse(foo.isRelativeSibling(of: anotherBar))
        XCTAssertFalse(anotherFoo.isRelativeSibling(of: foo))
        XCTAssertFalse(anotherFoo.isRelativeSibling(of: bar))
        XCTAssertFalse(bar.isRelativeSibling(of: anotherFoo))
        XCTAssertFalse(bar.isRelativeSibling(of: anotherBar))
        XCTAssertFalse(anotherBar.isRelativeSibling(of: foo))
        XCTAssertFalse(anotherBar.isRelativeSibling(of: bar))
        
        // Now let's test the positive test cases.
        XCTAssertTrue(foo.isRelativeSibling(of: bar))
        XCTAssertTrue(bar.isRelativeSibling(of: foo))
        XCTAssertTrue(anotherFoo.isRelativeSibling(of: anotherBar))
        XCTAssertTrue(anotherBar.isRelativeSibling(of: anotherFoo))
    }
    
    /// Tests that **groupSiblings(by viewTypes:)** works properly.
    func testGroupSiblingsByViewTypes() {
        let view: UIView = UIView()
        let firstSubview: UIControl = UIControl()
        view.addSubview(firstSubview)

        // Grouping a view that has no superview should return nothing.
        XCTAssertTrue(view.groupSiblings(by: [UIView.self]).isEmpty)
        
        // Grouping a subview that has a superview but no other siblings should return nothing.
        XCTAssertTrue(firstSubview.groupSiblings(by: [UIControl.self]).isEmpty)
        
        // Now let's add more siblings.
        let secondSubview: UIButton = UIButton()
        view.addSubview(secondSubview)
        let thirdSubview: UILabel = UILabel()
        view.addSubview(thirdSubview)
        
        // Verify our sibling relationship is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(view.superview)
        XCTAssertEqual(3, view.subviews.count)
        XCTAssertTrue(view.subviews[0] === firstSubview)
        XCTAssertTrue(view.subviews[1] === secondSubview)
        XCTAssertTrue(view.subviews[2] === thirdSubview)
        XCTAssertTrue(view === firstSubview.superview)
        XCTAssertTrue(firstSubview.subviews.isEmpty)
        XCTAssertTrue(view === secondSubview.superview)
        XCTAssertTrue(secondSubview.subviews.isEmpty)
        XCTAssertTrue(view === thirdSubview.superview)
        XCTAssertTrue(thirdSubview.subviews.isEmpty)

        // Now if we attempt to group by the wrong viewTypes, it should return nothing.
        XCTAssertTrue(firstSubview.groupSiblings(by: [UISlider.self, UITableView.self]).isEmpty)
        XCTAssertTrue(secondSubview.groupSiblings(by: [UISlider.self, UITableView.self]).isEmpty)
        XCTAssertTrue(thirdSubview.groupSiblings(by: [UISlider.self, UITableView.self]).isEmpty)

        // No viewTypes should return nothing.
        let viewTypes: [UIView.Type] = []
        var siblings: [String : [UIView]] = firstSubview.groupSiblings(by: viewTypes)
        XCTAssertTrue(siblings.isEmpty)
        siblings = secondSubview.groupSiblings(by: viewTypes)
        XCTAssertTrue(siblings.isEmpty)
        siblings = thirdSubview.groupSiblings(by: viewTypes)
        XCTAssertTrue(siblings.isEmpty)

        // One matching viewType.
        let buttonKey: String = String(describing: UIButton.self)
        siblings = firstSubview.groupSiblings(by: [UIButton.self])
        XCTAssertEqual(1, siblings.count)
        XCTAssertEqual(1, siblings[buttonKey]!.count)
        XCTAssertTrue(secondSubview === siblings[buttonKey]![0])

        // Multiple matching viewTypes.
        let labelKey: String = String(describing: UILabel.self)
        siblings = firstSubview.groupSiblings(by: [UIButton.self, UILabel.self])
        XCTAssertEqual(2, siblings.count)
        XCTAssertEqual(1, siblings[buttonKey]!.count)
        XCTAssertEqual(1, siblings[labelKey]!.count)
        XCTAssertTrue(secondSubview === siblings[buttonKey]![0])
        XCTAssertTrue(thirdSubview === siblings[labelKey]![0])
        
        // Some matching viewTypes, one does not match should result in no change.
        siblings = firstSubview.groupSiblings(by: [UIButton.self, UILabel.self, UISlider.self])
        XCTAssertEqual(2, siblings.count)
        XCTAssertEqual(1, siblings[buttonKey]!.count)
        XCTAssertEqual(1, siblings[labelKey]!.count)
        XCTAssertTrue(secondSubview === siblings[buttonKey]![0])
        XCTAssertTrue(thirdSubview === siblings[labelKey]![0])
    }
    
    /// Tests that the return value of **groupSiblings(by viewTypes:)** is ordered properly. This occurs if one or more siblings are of the same
    /// **UIView.Type**, since that would place them in the same **Array**. In that case the expected order is whichever sibling is closer to the
    /// zero index.
    func testGroupSiblingsByViewTypesOrderedDuplicates() {
        let view: UIView = UIView()
        let firstSubview: UIView = UIView()
        view.addSubview(firstSubview)
        let secondSubview: UIView = UIView()
        view.addSubview(secondSubview)
        let thirdSubview: UIView = UIView()
        view.addSubview(thirdSubview)
        
        // Verify our sibling relationship is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(view.superview)
        XCTAssertEqual(3, view.subviews.count)
        XCTAssertTrue(view.subviews[0] === firstSubview)
        XCTAssertTrue(view.subviews[1] === secondSubview)
        XCTAssertTrue(view.subviews[2] === thirdSubview)
        XCTAssertTrue(view === firstSubview.superview)
        XCTAssertTrue(firstSubview.subviews.isEmpty)
        XCTAssertTrue(view === secondSubview.superview)
        XCTAssertTrue(secondSubview.subviews.isEmpty)
        XCTAssertTrue(view === thirdSubview.superview)
        XCTAssertTrue(thirdSubview.subviews.isEmpty)
        
        // Group the siblings and make sure the two other siblings are found and they are in the correct order (based on distance to the zero index).
        let viewKey: String = String(describing: UIView.self)
        var siblings: [String : [UIView]] = firstSubview.groupSiblings(by: [UIView.self])
        XCTAssertEqual(1, siblings.count)
        XCTAssertEqual(2, siblings[viewKey]!.count)
        XCTAssertTrue(secondSubview === siblings[viewKey]![0])
        XCTAssertTrue(thirdSubview === siblings[viewKey]![1])
        
        siblings = secondSubview.groupSiblings(by: [UIView.self])
        XCTAssertEqual(1, siblings.count)
        XCTAssertEqual(2, siblings[viewKey]!.count)
        XCTAssertTrue(firstSubview === siblings[viewKey]![0])
        XCTAssertTrue(thirdSubview === siblings[viewKey]![1])

        siblings = thirdSubview.groupSiblings(by: [UIView.self])
        XCTAssertEqual(1, siblings.count)
        XCTAssertEqual(2, siblings[viewKey]!.count)
        XCTAssertTrue(firstSubview === siblings[viewKey]![0])
        XCTAssertTrue(secondSubview === siblings[viewKey]![1])
    }
    
    /// Tests that **groupSiblings(by tags:)** works properly.
    func testGroupSiblingsByTags() {
        let view: UIView = UIView()
        view.tag = 1
        let firstSubview: UIView = UIView()
        firstSubview.tag = 1
        view.addSubview(firstSubview)
        
        // Grouping a view that has no superview should return nothing.
        XCTAssertTrue(view.groupSiblings(by: [1]).isEmpty)
        
        // Grouping a subview that has a superview but no other siblings should return nothing.
        XCTAssertTrue(firstSubview.groupSiblings(by: [1]).isEmpty)
        
        // Now let's add more siblings.
        let secondSubview: UIButton = UIButton()
        secondSubview.tag = 2
        view.addSubview(secondSubview)
        let thirdSubview: UILabel = UILabel()
        thirdSubview.tag = 3
        view.addSubview(thirdSubview)
        
        // Verify our sibling relationship is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(view.superview)
        XCTAssertEqual(3, view.subviews.count)
        XCTAssertTrue(view.subviews[0] === firstSubview)
        XCTAssertTrue(view.subviews[1] === secondSubview)
        XCTAssertTrue(view.subviews[2] === thirdSubview)
        XCTAssertEqual(1, view.tag)
        XCTAssertTrue(view === firstSubview.superview)
        XCTAssertTrue(firstSubview.subviews.isEmpty)
        XCTAssertEqual(1, firstSubview.tag)
        XCTAssertTrue(view === secondSubview.superview)
        XCTAssertTrue(secondSubview.subviews.isEmpty)
        XCTAssertEqual(2, secondSubview.tag)
        XCTAssertTrue(view === thirdSubview.superview)
        XCTAssertTrue(thirdSubview.subviews.isEmpty)
        XCTAssertEqual(3, thirdSubview.tag)

        // Now if we attempt to group by the wrong tags, it should return nothing.
        XCTAssertTrue(firstSubview.groupSiblings(by: [4, 5]).isEmpty)
        XCTAssertTrue(secondSubview.groupSiblings(by: [4, 5]).isEmpty)
        XCTAssertTrue(thirdSubview.groupSiblings(by: [4, 5]).isEmpty)
        
        // No tags should return nothing.
        let tags: [Int] = []
        var siblings: [Int : [UIView]] = firstSubview.groupSiblings(by: tags)
        XCTAssertTrue(siblings.isEmpty)
        siblings = secondSubview.groupSiblings(by: tags)
        XCTAssertTrue(siblings.isEmpty)
        siblings = thirdSubview.groupSiblings(by: tags)
        XCTAssertTrue(siblings.isEmpty)
        
        // One matching tag.
        siblings = firstSubview.groupSiblings(by: [3])
        XCTAssertEqual(1, siblings.count)
        XCTAssertEqual(1, siblings[3]!.count)
        XCTAssertTrue(thirdSubview === siblings[3]![0])
        
        // Multiple matching tags.
        siblings = firstSubview.groupSiblings(by: [2, 3])
        XCTAssertEqual(2, siblings.count)
        XCTAssertEqual(1, siblings[2]!.count)
        XCTAssertEqual(1, siblings[3]!.count)
        XCTAssertTrue(secondSubview === siblings[2]![0])
        XCTAssertTrue(thirdSubview === siblings[3]![0])
        
        // Some matching tags, one does not match should result in no change.
        siblings = firstSubview.groupSiblings(by: [2, 3, 4])
        XCTAssertEqual(2, siblings.count)
        XCTAssertEqual(1, siblings[2]!.count)
        XCTAssertEqual(1, siblings[3]!.count)
        XCTAssertTrue(secondSubview === siblings[2]![0])
        XCTAssertTrue(thirdSubview === siblings[3]![0])
    }
    
    /// Tests that the return value of **groupSiblings(by tags:)** is ordered properly. This occurs if one or more sibling is of the same **tag**, since
    /// that would place them in the same **Array**. In that case the expected order is whichever sibling was closer to the first **subview**.
    func testGroupSiblingsByTagsOrderedDuplicates() {
        let view: UIView = UIView()
        view.tag = 1
        let firstSubview: UIView = UIView()
        firstSubview.tag = 1
        view.addSubview(firstSubview)
        let secondSubview: UIView = UIView()
        secondSubview.tag = 1
        view.addSubview(secondSubview)
        let thirdSubview: UIView = UIView()
        thirdSubview.tag = 1
        view.addSubview(thirdSubview)
        
        // Verify our sibling relationship is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(view.superview)
        XCTAssertEqual(3, view.subviews.count)
        XCTAssertTrue(view.subviews[0] === firstSubview)
        XCTAssertTrue(view.subviews[1] === secondSubview)
        XCTAssertTrue(view.subviews[2] === thirdSubview)
        XCTAssertEqual(1, view.tag)
        XCTAssertTrue(view === firstSubview.superview)
        XCTAssertTrue(firstSubview.subviews.isEmpty)
        XCTAssertEqual(1, firstSubview.tag)
        XCTAssertTrue(view === secondSubview.superview)
        XCTAssertTrue(secondSubview.subviews.isEmpty)
        XCTAssertEqual(1, secondSubview.tag)
        XCTAssertTrue(view === thirdSubview.superview)
        XCTAssertTrue(thirdSubview.subviews.isEmpty)
        XCTAssertEqual(1, thirdSubview.tag)
        
        // Group the siblings and make sure the two siblings are found and they are in the correct order (based on distance to the first subview).
        var siblings: [Int : [UIView]] = firstSubview.groupSiblings(by: [1])
        XCTAssertEqual(1, siblings.count)
        XCTAssertEqual(2, siblings[1]!.count)
        XCTAssertTrue(secondSubview === siblings[1]![0])
        XCTAssertTrue(thirdSubview === siblings[1]![1])
        
        siblings = secondSubview.groupSiblings(by: [1])
        XCTAssertEqual(1, siblings.count)
        XCTAssertEqual(2, siblings[1]!.count)
        XCTAssertTrue(firstSubview === siblings[1]![0])
        XCTAssertTrue(thirdSubview === siblings[1]![1])
        
        siblings = thirdSubview.groupSiblings(by: [1])
        XCTAssertEqual(1, siblings.count)
        XCTAssertEqual(2, siblings[1]!.count)
        XCTAssertTrue(firstSubview === siblings[1]![0])
        XCTAssertTrue(secondSubview === siblings[1]![1])
    }
    
}

