//
//  AncestorTests.swift
//  RelativeViewTests
//
//  Created by Jae Yeum on 9/17/18.
//  Copyright © 2018 RelativeView - Jae Yeum. All rights reserved.
//

import XCTest
@testable import RelativeView

class AncestorTests: XCTestCase {

    /// Tests that **findFirstAncestor(by viewTypes:)** works properly.
    func testFindFirstAncestorByViewTypes() {
        // No ancestor should return nil.
        let view: UIView = UIView()
        XCTAssertNil(view.superview)
        XCTAssertNil(view.findFirstAncestor(by: [UIButton.self]))
        
        // No viewTypes should return nil.
        let viewTypes: [UIView.Type] = []
        XCTAssertNil(view.findFirstAncestor(by: viewTypes))
        
        // The wrong viewType (no matches) should return nil.
        let ancestor: UITableViewCell = UITableViewCell()
        ancestor.addSubview(view)
        XCTAssertNil(view.findFirstAncestor(by: [UIButton.self]))
        
        // The correct viewTypes should return the ancestor.
        XCTAssertTrue(ancestor === view.findFirstAncestor(by: [UITableViewCell.self]))
        
        // If we start at the ancestor, the ancestor of that ancestor is nil since there is no higher ancestor so this should return nil.
        XCTAssertNil(ancestor.findFirstAncestor(by: [UITableViewCell.self]))
        
        // Now test more than one viewType. In this case both of the viewTypes should result in a match, but the first ancestor found should match.
        let superAncestor: UITableView = UITableView()
        superAncestor.addSubview(ancestor)
        XCTAssertTrue(ancestor === view.findFirstAncestor(by: [UITableViewCell.self, UITableView.self]))
        XCTAssertTrue(ancestor === view.findFirstAncestor(by: [UITableView.self, UITableViewCell.self]))
        
        // Make sure if only one matches we get that one even if it's after one that doesn't match.
        XCTAssertTrue(ancestor === view.findFirstAncestor(by: [UIButton.self, UITableViewCell.self]))
        XCTAssertTrue(superAncestor === view.findFirstAncestor(by: [UIButton.self, UITableView.self]))
    }
    
    /// Tests that **findFirstAncestor(by tags:)** works properly.
    func testFindFirstAncestorByTags() {
        // No ancestor should return nil.
        let view: UIView = UIView()
        XCTAssertNil(view.superview)
        XCTAssertNil(view.findFirstAncestor(by: [0]))
        
        // No tags should return nil.
        let tags: [Int] = []
        XCTAssertNil(view.findFirstAncestor(by: tags))
        
        // The wrong tag (no matches) should return nil.
        let ancestor: UIView = UIView()
        ancestor.tag = 1
        ancestor.addSubview(view)
        XCTAssertNil(view.findFirstAncestor(by: [-1]))
        
        // The correct tags should return the ancestor.
        XCTAssertTrue(ancestor === view.findFirstAncestor(by: [1]))
        
        // If we start at the ancestor, the ancestor of that ancestor is nil since there is no higher ancestor so this should return nil.
        XCTAssertNil(ancestor.findFirstAncestor(by: [1]))
        
        // Now test more than one tag. In this case both of the tags should result in a match, but the first ancestor found should match.
        let superAncestor: UIView = UIView()
        superAncestor.tag = 2
        superAncestor.addSubview(ancestor)
        XCTAssertTrue(ancestor === view.findFirstAncestor(by: [1, 2]))
        XCTAssertTrue(ancestor === view.findFirstAncestor(by: [2, 1]))
        
        // Make sure if only one matches we get that one even if it's after one that doesn't match.
        XCTAssertTrue(ancestor === view.findFirstAncestor(by: [-1, 1]))
        XCTAssertTrue(superAncestor === view.findFirstAncestor(by: [-1, 2]))
    }
    
    /// Tests that **isRelativeAncestor(of view:)** works properly.
    func testIsRelativeAncestorOfView() {
        // Set up three levels of ancestry. The bottom of the ancestry is view, above view is furtherAncestor, above furtherAncestor is furthestAncestor
        // at the top of the ancestry.
        let view: UIView = UIView()
        let furtherAncestor: UIView = UIView()
        furtherAncestor.addSubview(view)
        let furthestAncestor: UIView = UIView()
        furthestAncestor.addSubview(furtherAncestor)
        
        // Verify our ancestry is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(furthestAncestor.superview)
        XCTAssertEqual(1, furthestAncestor.subviews.count)
        XCTAssertTrue(furthestAncestor.subviews[0] === furtherAncestor)
        XCTAssertTrue(furthestAncestor == furtherAncestor.superview)
        XCTAssertEqual(1, furtherAncestor.subviews.count)
        XCTAssertTrue(furtherAncestor.subviews[0] === view)
        XCTAssertTrue(furtherAncestor == view.superview)
        XCTAssertTrue(view.subviews.isEmpty)
        
        // Let's test that if a check for ancestry occurs on a random view with no ancestor it returns false.
        XCTAssertFalse(UIView().isRelativeAncestor(of: UIView()))

        // Since view is at the bottom of the ancestry, both furtherAncestor and furthestAncestors are ancestors.
        XCTAssertTrue(furtherAncestor.isRelativeAncestor(of: view))
        XCTAssertTrue(furthestAncestor.isRelativeAncestor(of: view))
        
        // None of the views can be the ancestor of themselves.
        XCTAssertFalse(view.isRelativeAncestor(of: view))
        XCTAssertFalse(furtherAncestor.isRelativeAncestor(of: furtherAncestor))
        XCTAssertFalse(furthestAncestor.isRelativeAncestor(of: furthestAncestor))
        
        // The wrong ancestor should return false.
        XCTAssertFalse(view.isRelativeAncestor(of: furtherAncestor))
        XCTAssertFalse(view.isRelativeAncestor(of: furthestAncestor))
    }
    
    /// Tests that **groupAncestors(by viewTypes:)** works properly.
    func testGroupAncestorsViewByTypes() {
        // No ancestors should return nil.
        let view: UIView = UIView()
        XCTAssertNil(view.superview)
        XCTAssertTrue(view.groupAncestors(by: [UIView.self]).isEmpty)
        
        // Now let's set up three levels of ancestry with imageViewAncestor on the top, buttonAncestor below it and view at the bottom.
        let buttonAncestor: UIButton = UIButton()
        buttonAncestor.addSubview(view)
        let imageViewAncestor: UIImageView = UIImageView()
        imageViewAncestor.addSubview(buttonAncestor)
        
        // Verify our ancestry is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(imageViewAncestor.superview)
        XCTAssertEqual(1, imageViewAncestor.subviews.count)
        XCTAssertTrue(imageViewAncestor.subviews[0] === buttonAncestor)
        XCTAssertTrue(imageViewAncestor == buttonAncestor.superview)
        XCTAssertEqual(1, buttonAncestor.subviews.count)
        XCTAssertTrue(buttonAncestor.subviews[0] === view)
        XCTAssertTrue(buttonAncestor == view.superview)
        XCTAssertTrue(view.subviews.isEmpty)

        // Now if we attempt to group by the wrong viewTypes, it should return nothing.
        XCTAssertTrue(view.groupAncestors(by: [UISlider.self, UITextField.self]).isEmpty)
        
        // No viewTypes should return nothing.
        let viewTypes: [UIView.Type] = []
        var ancestors: [String : [UIView]] = view.groupAncestors(by: viewTypes)
        XCTAssertTrue(ancestors.isEmpty)
        
        // One matching viewType.
        let buttonKey: String = String(describing: UIButton.self)
        ancestors = view.groupAncestors(by: [UIButton.self])
        XCTAssertEqual(1, ancestors.count)
        XCTAssertEqual(1, ancestors[buttonKey]!.count)
        XCTAssertTrue(buttonAncestor === ancestors[buttonKey]![0])
        
        // All matching viewTypes.
        let imageViewKey: String = String(describing: UIImageView.self)
        ancestors = view.groupAncestors(by: [UIButton.self, UIImageView.self])
        XCTAssertEqual(2, ancestors.count)
        XCTAssertEqual(1, ancestors[buttonKey]!.count)
        XCTAssertEqual(1, ancestors[imageViewKey]!.count)
        XCTAssertTrue(buttonAncestor === ancestors[buttonKey]![0])
        XCTAssertTrue(imageViewAncestor === ancestors[imageViewKey]![0])
        
        // Some matching tags, one does not match should result in no change.
        ancestors = view.groupAncestors(by: [UIButton.self, UIImageView.self, UISlider.self])
        XCTAssertEqual(2, ancestors.count)
        XCTAssertEqual(1, ancestors[buttonKey]!.count)
        XCTAssertEqual(1, ancestors[imageViewKey]!.count)
        XCTAssertTrue(buttonAncestor === ancestors[buttonKey]![0])
        XCTAssertTrue(imageViewAncestor === ancestors[imageViewKey]![0])
    }
    
    /// Tests that the return value of **groupAncestors(by viewTypes:)** is ordered properly. This occurs if one or more ancestor is of the same
    /// **UIView.Type**, since that would place them in the same **Array**. In that case the expected order is such where the first ancestor in the
    /// **Array** is the closest ancestor relative to self.
    func testGroupAncestorsByViewTypesOrderedDuplicates() {
        // Set up three levels of ancestry, all of the same viewType.
        let view: UIButton = UIButton()
        let furtherAncestor: UIButton = UIButton()
        furtherAncestor.addSubview(view)
        let furthestAncestor: UIButton = UIButton()
        furthestAncestor.addSubview(furtherAncestor)
        
        // Verify our ancestry is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(furthestAncestor.superview)
        XCTAssertEqual(1, furthestAncestor.subviews.count)
        XCTAssertTrue(furthestAncestor.subviews[0] === furtherAncestor)
        XCTAssertTrue(furthestAncestor == furtherAncestor.superview)
        XCTAssertEqual(1, furtherAncestor.subviews.count)
        XCTAssertTrue(furtherAncestor.subviews[0] === view)
        XCTAssertTrue(furtherAncestor == view.superview)
        XCTAssertTrue(view.subviews.isEmpty)
        
        // Group the ancestors at view.
        let ancestors: [String : [UIView]] = view.groupAncestors(by: [UIButton.self])
        
        // Make sure the two ancestors are found and they are in the correct order.
        let buttonKey: String = String(describing: UIButton.self)
        XCTAssertEqual(1, ancestors.count)
        XCTAssertEqual(2, ancestors[buttonKey]!.count)
        XCTAssertTrue(furtherAncestor === ancestors[buttonKey]![0])
        XCTAssertTrue(furthestAncestor === ancestors[buttonKey]![1])
    }
    
    /// Tests that **groupAncestors(by tags:)** works properly.
    func testGroupAncestorsByTags() {
        // No ancestors should return nil.
        let view: UIView = UIView()
        view.tag = 1
        XCTAssertNil(view.superview)
        XCTAssertTrue(view.groupAncestors(by: [1]).isEmpty)
        
        // Now let's set up three levels of ancestry. There's a UIView with tag 3 on the top, UIView with tag 2 below it and view with tag 1 at the bottom.
        let tag2Ancestor: UIView = UIView()
        tag2Ancestor.tag = 2
        tag2Ancestor.addSubview(view)
        let tag3Ancestor: UIView = UIView()
        tag3Ancestor.tag = 3
        tag3Ancestor.addSubview(tag2Ancestor)
        
        // Verify our ancestry is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(tag3Ancestor.superview)
        XCTAssertEqual(1, tag3Ancestor.subviews.count)
        XCTAssertTrue(tag3Ancestor.subviews[0] === tag2Ancestor)
        XCTAssertEqual(3, tag3Ancestor.tag)
        XCTAssertTrue(tag3Ancestor == tag2Ancestor.superview)
        XCTAssertEqual(1, tag2Ancestor.subviews.count)
        XCTAssertTrue(tag2Ancestor.subviews[0] === view)
        XCTAssertEqual(2, tag2Ancestor.tag)
        XCTAssertTrue(tag2Ancestor == view.superview)
        XCTAssertTrue(view.subviews.isEmpty)
        XCTAssertEqual(1, view.tag)

        // Now if we attempt to group by the wrong tags, it should return nothing.
        XCTAssertTrue(view.groupAncestors(by: [4, 5]).isEmpty)
        
        // No tags should return nothing.
        let tags: [Int] = []
        var ancestors: [Int : [UIView]] = view.groupAncestors(by: tags)
        XCTAssertTrue(ancestors.isEmpty)
        
        // One matching tag.
        ancestors = view.groupAncestors(by: [2])
        XCTAssertEqual(1, ancestors.count)
        XCTAssertEqual(1, ancestors[2]!.count)
        XCTAssertTrue(tag2Ancestor === ancestors[2]![0])
        
        // All matching tags.
        ancestors = view.groupAncestors(by: [2, 3])
        XCTAssertEqual(2, ancestors.count)
        XCTAssertEqual(1, ancestors[2]!.count)
        XCTAssertEqual(1, ancestors[3]!.count)
        XCTAssertTrue(tag2Ancestor === ancestors[2]![0])
        XCTAssertTrue(tag3Ancestor === ancestors[3]![0])
        
        // Some matching tags, one does not match should result in no change.
        ancestors = view.groupAncestors(by: [2, 3, 4])
        XCTAssertEqual(2, ancestors.count)
        XCTAssertEqual(1, ancestors[2]!.count)
        XCTAssertEqual(1, ancestors[3]!.count)
        XCTAssertTrue(tag2Ancestor === ancestors[2]![0])
        XCTAssertTrue(tag3Ancestor === ancestors[3]![0])
    }
    
    /// Tests that the return value of **groupAncestors(by tags:)** is ordered properly. This occurs if one or more ancestor is of the same
    /// **tag**, since that would place them in the same **Array**. In that case the expected order is such where the first ancestor in the
    /// **Array** is the closest ancestor relative to self.
    func testGroupAncestorsByTagsOrderedDuplicates() {
        // Set up three levels of ancestry, all of the same tag.
        let view: UIView = UIView()
        view.tag = 1
        let furtherAncestor: UIView = UIView()
        furtherAncestor.tag = 1
        furtherAncestor.addSubview(view)
        let furthestAncestor: UIView = UIView()
        furthestAncestor.tag = 1
        furthestAncestor.addSubview(furtherAncestor)
        
        // Verify our ancestry is correct, it would suck if we tested with the wrong setup.
        XCTAssertNil(furthestAncestor.superview)
        XCTAssertEqual(1, furthestAncestor.subviews.count)
        XCTAssertTrue(furthestAncestor.subviews[0] === furtherAncestor)
        XCTAssertEqual(1, furthestAncestor.tag)
        XCTAssertTrue(furthestAncestor == furtherAncestor.superview)
        XCTAssertEqual(1, furtherAncestor.subviews.count)
        XCTAssertTrue(furtherAncestor.subviews[0] === view)
        XCTAssertEqual(1, furtherAncestor.tag)
        XCTAssertTrue(furtherAncestor == view.superview)
        XCTAssertTrue(view.subviews.isEmpty)
        XCTAssertEqual(1, view.tag)

        // Group the ancestors at view.
        let ancestors: [Int : [UIView]] = view.groupAncestors(by: [1])
        
        // Make sure the two ancestors are found and they are in the correct order.
        XCTAssertEqual(1, ancestors.count)
        XCTAssertEqual(2, ancestors[1]!.count)
        XCTAssertTrue(furtherAncestor === ancestors[1]![0])
        XCTAssertTrue(furthestAncestor === ancestors[1]![1])
    }
    
}

