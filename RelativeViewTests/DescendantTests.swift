//
//  DescendantTests.swift
//  RelativeViewTests
//
//  Created by Jae Yeum on 9/17/18.
//  Copyright © 2018 RelativeView - Jae Yeum. All rights reserved.
//

import XCTest
@testable import RelativeView

class DescendantTests: XCTestCase {
    
    private let makeSubview: (UIView, Int) -> UIView = {
        (view: UIView, tag: Int) in
        let subview: UIView = UIView()
        subview.tag = tag
        view.addSubview(subview)
        return subview
    }
    
    /// Tests that depthFirstTraverse(_: traversal:) works properly. This verifies the traversal order.
    func testDepthFirstTraverse() {
        // Let's start with a tree that has no descendants. Nothing should have been traversed.
        let root: UIView = UIView()
        root.tag = 1

        // Let's define a traversal closure that just captures the traversedTags Array, appending the tag of the traversed UIView to it.
        var traversedTags: [Int] = []
        let traversal: (UIView) -> Bool = {
            (view: UIView) -> Bool in
            traversedTags.append(view.tag)
            return true
        }
        XCTAssertTrue(root.depthFirstTraverse(root, traversal: traversal))
        XCTAssertTrue(traversedTags.isEmpty)
        
        // Now let's add a single descendant. Now we should traverse that descendant.
        let firstDescendant: UIView = makeSubview(root, 2)
        XCTAssertTrue(root.depthFirstTraverse(root, traversal: traversal))
        XCTAssertEqual(1, traversedTags.count)
        XCTAssertEqual(2, traversedTags[0])
        traversedTags.removeAll()
        
        // Now let's add another descendant under UIView (a sibiling to firstDescendant).
        let _: UIView = makeSubview(root, 3)
        XCTAssertTrue(root.depthFirstTraverse(root, traversal: traversal))
        XCTAssertEqual(2, traversedTags.count)
        XCTAssertEqual(2, traversedTags[0])
        XCTAssertEqual(3, traversedTags[1])
        traversedTags.removeAll()
        
        // Now let's add two descendants under firstDescendant and make sure the order is correct (everything under firstDescendant should be traversed
        // first).
        let _: UIView = makeSubview(firstDescendant, 4)
        let _: UIView = makeSubview(firstDescendant, 5)
        XCTAssertTrue(root.depthFirstTraverse(root, traversal: traversal))
        XCTAssertEqual(4, traversedTags.count)
        XCTAssertEqual(2, traversedTags[0])
        XCTAssertEqual(4, traversedTags[1])
        XCTAssertEqual(5, traversedTags[2])
        XCTAssertEqual(3, traversedTags[3])
        traversedTags.removeAll()
    }
    
    /// Tests that depthFirstTraverse(_: traversal:) works properly. This verifies the interrupt behavior.
    func testDepthFirstTraverseInterrupt() {
        // Let's start with a tree that has a total height of three. Starting at the root there are two descendants and under the first/left descendant
        // there are two more children.
        let root: UIView = UIView()
        root.tag = 1
        
        // Let's define a traversal closure that just captures the traversedTags Array, appending the tag of the traversed UIView to it. This also captures
        // a tag that should cause an interruption of traversal.
        var traversedTags: [Int] = []
        var interruptTag: Int = 1
        let traversal: (UIView) -> Bool = {
            (view: UIView) -> Bool in
            traversedTags.append(view.tag)
            
            guard view.tag != interruptTag else {
                return false
            }
            return true
        }
        
        // Let's try a traversal just to make sure our layout is correct.
        let firstDescendant: UIView = makeSubview(root, 2)
        let _: UIView = makeSubview(root, 3)
        let _: UIView = makeSubview(firstDescendant, 4)
        let _: UIView = makeSubview(firstDescendant, 5)
        XCTAssertTrue(root.depthFirstTraverse(root, traversal: traversal))
        XCTAssertEqual(4, traversedTags.count)
        XCTAssertEqual(2, traversedTags[0])
        XCTAssertEqual(4, traversedTags[1])
        XCTAssertEqual(5, traversedTags[2])
        XCTAssertEqual(3, traversedTags[3])
        traversedTags.removeAll()
        
        // Now let's try different interrupt tags and make sure interruption behaves properly. Starting with tag 2. If tag 2 is interrupted, since that's
        // the first traversed, all traversal should stop after tag 2.
        interruptTag = 2
        XCTAssertFalse(root.depthFirstTraverse(root, traversal: traversal))
        XCTAssertEqual(1, traversedTags.count)
        XCTAssertEqual(2, traversedTags[0])
        traversedTags.removeAll()
        
        // At tag 3, we should have tags 2 and the tags 4 and 5 from the descendants as well as 3.
        interruptTag = 3
        XCTAssertFalse(root.depthFirstTraverse(root, traversal: traversal))
        XCTAssertEqual(4, traversedTags.count)
        XCTAssertEqual(2, traversedTags[0])
        XCTAssertEqual(4, traversedTags[1])
        XCTAssertEqual(5, traversedTags[2])
        XCTAssertEqual(3, traversedTags[3])
        traversedTags.removeAll()
        
        // At tag 4, we should have tags 2 and 4, but 5 (the sibling of 4) should not have been traversed and neither should 3.
        interruptTag = 4
        XCTAssertFalse(root.depthFirstTraverse(root, traversal: traversal))
        XCTAssertEqual(2, traversedTags.count)
        XCTAssertEqual(2, traversedTags[0])
        XCTAssertEqual(4, traversedTags[1])
        traversedTags.removeAll()

        // At tag 5, we should have tags 2, 4 and 5, but tag 3 which is a sibling to 2 should not have been traversed.
        interruptTag = 5
        XCTAssertFalse(root.depthFirstTraverse(root, traversal: traversal))
        XCTAssertEqual(3, traversedTags.count)
        XCTAssertEqual(2, traversedTags[0])
        XCTAssertEqual(4, traversedTags[1])
        XCTAssertEqual(5, traversedTags[2])
        traversedTags.removeAll()
    }
    
    /// Tests that **isRelativeDescendant(of view:)** works properly.
    func testIsRelativeDescendantOfView() {
        // Let's set up three levels of descendancy. At the top is view with two descendants leftTagDescendant and rightTagDescendant under it,
        // where leftTagDescendant has furthestDescendant under it.
        let view: UIView = UIView()
        let leftDescendant: UIView = UIView()
        view.addSubview(leftDescendant)
        let rightDescendant: UIView = UIView()
        view.addSubview(rightDescendant)
        let furthestDescendant: UIView = UIView()
        leftDescendant.addSubview(furthestDescendant)
        
        // Verify our descendancy is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(view.superview)
        XCTAssertEqual(2, view.subviews.count)
        XCTAssertTrue(view.subviews[0] === leftDescendant)
        XCTAssertTrue(view.subviews[1] === rightDescendant)
        XCTAssertTrue(view === leftDescendant.superview)
        XCTAssertEqual(1, leftDescendant.subviews.count)
        XCTAssertTrue(leftDescendant.subviews[0] === furthestDescendant)
        XCTAssertTrue(leftDescendant === furthestDescendant.superview)
        XCTAssertTrue(view === rightDescendant.superview)
        XCTAssertTrue(rightDescendant.subviews.isEmpty)
        XCTAssertTrue(furthestDescendant.subviews.isEmpty)
        
        // Let's test that if a check for descendancy occurs on a random view with no descendants it returns false.
        XCTAssertFalse(UIView().isRelativeDescendant(of: UIView()))
        
        // Make sure views at the bottom of the descendancy are all descendants of the top of the descendancy.
        XCTAssertTrue(leftDescendant.isRelativeDescendant(of: view))
        XCTAssertTrue(rightDescendant.isRelativeDescendant(of: view))
        XCTAssertTrue(furthestDescendant.isRelativeDescendant(of: view))
        
        // None of the views can be the descendants of themselves.
        XCTAssertFalse(view.isRelativeDescendant(of: view))
        XCTAssertFalse(leftDescendant.isRelativeDescendant(of: leftDescendant))
        XCTAssertFalse(rightDescendant.isRelativeDescendant(of: rightDescendant))
        XCTAssertFalse(furthestDescendant.isRelativeDescendant(of: furthestDescendant))
        
        // The wrong descendant should return false.
        XCTAssertFalse(view.isRelativeDescendant(of: leftDescendant))
        XCTAssertFalse(view.isRelativeDescendant(of: rightDescendant))
        XCTAssertFalse(view.isRelativeDescendant(of: furthestDescendant))
    }
    
    /// Tests that **groupDescendants(by viewTypes:)** works properly.
    func testGroupDescendantsByViewTypes() {
        // No descendants should return nil.
        let view: UIView = UIView()
        XCTAssertTrue(view.subviews.isEmpty)
        XCTAssertTrue(view.groupDescendants(by: [UIView.self]).isEmpty)
        
        // Now let's set up three levels of descendancy. There's a UIView, with a UIButton as the first descendant and a UIControl as the second
        // descendant (they're siblings). The UIControl also has a UILabel descendant.
        let buttonDescendant: UIButton = UIButton()
        view.addSubview(buttonDescendant)
        let controlDescendant: UIControl = UIControl()
        view.addSubview(controlDescendant)
        let labelDescendant: UILabel = UILabel()
        controlDescendant.addSubview(labelDescendant)
        
        // Verify our descendancy is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(view.superview)
        XCTAssertEqual(2, view.subviews.count)
        XCTAssertTrue(view.subviews[0] === buttonDescendant)
        XCTAssertTrue(view.subviews[1] === controlDescendant)
        XCTAssertTrue(view === buttonDescendant.superview)
        XCTAssertTrue(buttonDescendant.subviews.isEmpty)
        XCTAssertTrue(view === controlDescendant.superview)
        XCTAssertEqual(1, controlDescendant.subviews.count)
        XCTAssertTrue(controlDescendant.subviews[0] === labelDescendant)
        XCTAssertTrue(controlDescendant === labelDescendant.superview)
        XCTAssertTrue(labelDescendant.subviews.isEmpty)
        
        // Now if we attempt to group by the wrong viewTypes, it should return nothing.
        XCTAssertTrue(view.groupDescendants(by: [UISlider.self, UITableView.self]).isEmpty)
        
        // No viewTypes should return nothing.
        let viewTypes: [UIView.Type] = []
        var descendants: [String : [UIView]] = view.groupDescendants(by: viewTypes)
        XCTAssertTrue(descendants.isEmpty)
        
        // One matching viewType.
        let buttonKey: String = String(describing: UIButton.self)
        descendants = view.groupDescendants(by: [UIButton.self])
        XCTAssertEqual(1, descendants.count)
        XCTAssertEqual(1, descendants[buttonKey]!.count)
        XCTAssertTrue(buttonDescendant === descendants[buttonKey]![0])
        
        // All matching viewTypes.
        let controlKey: String = String(describing: UIControl.self)
        let labelKey: String = String(describing: UILabel.self)
        descendants = view.groupDescendants(by: [UIButton.self, UIControl.self, UILabel.self])
        XCTAssertEqual(3, descendants.count)
        XCTAssertEqual(1, descendants[buttonKey]!.count)
        XCTAssertEqual(1, descendants[controlKey]!.count)
        XCTAssertEqual(1, descendants[labelKey]!.count)
        XCTAssertTrue(buttonDescendant === descendants[buttonKey]![0])
        XCTAssertTrue(controlDescendant === descendants[controlKey]![0])
        XCTAssertTrue(labelDescendant === descendants[labelKey]![0])
        
        // Some matching viewTypes, one does not match should result in no change.
        descendants = view.groupDescendants(by: [UIButton.self, UIControl.self, UILabel.self, UISlider.self])
        XCTAssertEqual(3, descendants.count)
        XCTAssertEqual(1, descendants[buttonKey]!.count)
        XCTAssertEqual(1, descendants[controlKey]!.count)
        XCTAssertEqual(1, descendants[labelKey]!.count)
        XCTAssertTrue(buttonDescendant === descendants[buttonKey]![0])
        XCTAssertTrue(controlDescendant === descendants[controlKey]![0])
        XCTAssertTrue(labelDescendant === descendants[labelKey]![0])
    }
    
    /// Tests that the return value of **groupDescendants(by viewTypes:)** is ordered properly. This occurs if one or more descendant is of the same
    /// **UIView.Type**, since that would place them in the same **Array**. In that case the expected order is depth-first.
    func testGroupDescendantsByViewTypesOrderedDuplicates() {
        // Now let's set up three levels of descendancy, button at the top with leftFurtherDescendant and rightFurtherDescendant under it as siblings,
        // then furthestDescendant under rightFurtherDescendant, all UIButtons.
        let button: UIButton = UIButton()
        let leftFurtherDescendant: UIButton = UIButton()
        button.addSubview(leftFurtherDescendant)
        let rightFurtherDescendant: UIButton = UIButton()
        button.addSubview(rightFurtherDescendant)
        let furthestDescendant: UIButton = UIButton()
        rightFurtherDescendant.addSubview(furthestDescendant)
        
        // Verify our descendancy is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(button.superview)
        XCTAssertEqual(2, button.subviews.count)
        XCTAssertTrue(button.subviews[0] === leftFurtherDescendant)
        XCTAssertTrue(button.subviews[1] === rightFurtherDescendant)
        XCTAssertTrue(button === leftFurtherDescendant.superview)
        XCTAssertTrue(leftFurtherDescendant.subviews.isEmpty)
        XCTAssertTrue(button === rightFurtherDescendant.superview)
        XCTAssertEqual(1, rightFurtherDescendant.subviews.count)
        XCTAssertTrue(rightFurtherDescendant.subviews[0] === furthestDescendant)
        XCTAssertTrue(rightFurtherDescendant === furthestDescendant.superview)
        XCTAssertTrue(furthestDescendant.subviews.isEmpty)
        
        // Group the descendants starting at button.
        var descendants: [String : [UIView]] = button.groupDescendants(by: [UIButton.self])
        
        // Make sure the three descendants are found and they are in the correct order (based on depth-first traversal).
        let buttonKey: String = String(describing: UIButton.self)
        XCTAssertEqual(1, descendants.count)
        XCTAssertEqual(3, descendants[buttonKey]!.count)
        XCTAssertTrue(leftFurtherDescendant === descendants[buttonKey]![0])
        XCTAssertTrue(rightFurtherDescendant === descendants[buttonKey]![1])
        XCTAssertTrue(furthestDescendant === descendants[buttonKey]![2])
    }
    
    /// Tests that **groupDescendants(by tags:)** works properly.
    func testGroupDescendantsByTags() {
        // No descendants should return nil.
        let view: UIView = UIView()
        view.tag = 1
        XCTAssertTrue(view.subviews.isEmpty)
        XCTAssertTrue(view.groupDescendants(by: [1]).isEmpty)
        
        // Now let's set up three levels of descendancy. There's a UIView with tag 1, with a UIView with tag 2 as the first descendant and a UIView with
        // tag 3 as the second descendant (they're siblings). The UIView with tag 2 also has a UIView with tag 4 descendant.
        let tag2Descendant: UIView = UIView()
        tag2Descendant.tag = 2
        view.addSubview(tag2Descendant)
        let tag3Descendant: UIView = UIView()
        tag3Descendant.tag = 3
        view.addSubview(tag3Descendant)
        let tag4Descendant: UIView = UIView()
        tag4Descendant.tag = 4
        tag2Descendant.addSubview(tag4Descendant)
        
        // Verify our descendancy is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(view.superview)
        XCTAssertEqual(2, view.subviews.count)
        XCTAssertTrue(view.subviews[0] === tag2Descendant)
        XCTAssertTrue(view.subviews[1] === tag3Descendant)
        XCTAssertEqual(1, view.tag)
        XCTAssertTrue(view === tag2Descendant.superview)
        XCTAssertEqual(1, tag2Descendant.subviews.count)
        XCTAssertTrue(tag2Descendant.subviews[0] === tag4Descendant)
        XCTAssertEqual(2, tag2Descendant.tag)
        XCTAssertTrue(view === tag3Descendant.superview)
        XCTAssertTrue(tag3Descendant.subviews.isEmpty)
        XCTAssertEqual(3, tag3Descendant.tag)
        XCTAssertTrue(tag2Descendant === tag4Descendant.superview)
        XCTAssertTrue(tag4Descendant.subviews.isEmpty)
        XCTAssertEqual(4, tag4Descendant.tag)
        
        // Now if we attempt to group by the wrong tags, it should return nothing.
        XCTAssertTrue(view.groupDescendants(by: [5, 6]).isEmpty)
        
        // No tags should return nothing.
        let tags: [Int] = []
        var descendants: [Int : [UIView]] = view.groupDescendants(by: tags)
        XCTAssertTrue(descendants.isEmpty)
        
        // One matching tag.
        descendants = view.groupDescendants(by: [2])
        XCTAssertEqual(1, descendants.count)
        XCTAssertEqual(1, descendants[2]!.count)
        XCTAssertEqual(2, descendants[2]![0].tag)
        
        // All matching tags.
        descendants = view.groupDescendants(by: [2, 3, 4])
        XCTAssertEqual(1, descendants[2]!.count)
        XCTAssertEqual(1, descendants[3]!.count)
        XCTAssertEqual(1, descendants[4]!.count)
        XCTAssertEqual(2, descendants[2]![0].tag)
        XCTAssertEqual(3, descendants[3]![0].tag)
        XCTAssertEqual(4, descendants[4]![0].tag)
        
        // Some matching tags, one does not match should result in no change.
        descendants = view.groupDescendants(by: [2, 3, 4, 5])
        XCTAssertEqual(1, descendants[2]!.count)
        XCTAssertEqual(1, descendants[3]!.count)
        XCTAssertEqual(1, descendants[4]!.count)
        XCTAssertEqual(2, descendants[2]![0].tag)
        XCTAssertEqual(3, descendants[3]![0].tag)
        XCTAssertEqual(4, descendants[4]![0].tag)
    }
    
    /// Tests that the return value of **groupDescendants(by tags:)** is ordered properly. This occurs if one or more descendant is of the same
    /// **tag**, since that would place them in the same **Array**. In that case the expected order is depth-first.
    func testGroupDescendantsByTagsOrderedDuplicates() {
        // Now let's set up three levels of descendancy. At the top is view with two descendants leftTagDescendant and rightTagDescendant under it,
        // where leftTagDescendant has furthestDescendant under it, all with tag 1.
        let view: UIView = UIView()
        view.tag = 1
        let leftTagDescendant: UIView = UIView()
        leftTagDescendant.tag = 1
        view.addSubview(leftTagDescendant)
        let rightTagDescendant: UIView = UIView()
        rightTagDescendant.tag = 1
        view.addSubview(rightTagDescendant)
        let furthestDescendant: UIView = UIView()
        furthestDescendant.tag = 1
        leftTagDescendant.addSubview(furthestDescendant)
        
        // Verify our descendancy is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(view.superview)
        XCTAssertEqual(2, view.subviews.count)
        XCTAssertTrue(view.subviews[0] === leftTagDescendant)
        XCTAssertTrue(view.subviews[1] === rightTagDescendant)
        XCTAssertEqual(1, view.tag)
        XCTAssertTrue(view === leftTagDescendant.superview)
        XCTAssertEqual(1, leftTagDescendant.subviews.count)
        XCTAssertTrue(leftTagDescendant.subviews[0] === furthestDescendant)
        XCTAssertEqual(1, leftTagDescendant.tag)
        XCTAssertTrue(view === rightTagDescendant.superview)
        XCTAssertTrue(rightTagDescendant.subviews.isEmpty)
        XCTAssertEqual(1, rightTagDescendant.tag)
        XCTAssertTrue(leftTagDescendant === furthestDescendant.superview)
        XCTAssertTrue(furthestDescendant.subviews.isEmpty)
        XCTAssertEqual(1, furthestDescendant.tag)
        
        // Group the descendants starting at button.
        var descendants: [Int : [UIView]] = view.groupDescendants(by: [1])
        
        // Make sure the three descendants are found and they are in the correct order (based on depth-first traversal).
        XCTAssertEqual(1, descendants.count)
        XCTAssertEqual(3, descendants[1]!.count)
        XCTAssertTrue(leftTagDescendant === descendants[1]![0])
        XCTAssertTrue(furthestDescendant === descendants[1]![1])
        XCTAssertTrue(rightTagDescendant === descendants[1]![2])
    }
    
}

