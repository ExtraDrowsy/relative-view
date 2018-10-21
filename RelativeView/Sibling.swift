//
//  Sibling.swift
//  RelativeView
//
//  Created by Jae Yeum on 9/17/18.
//  Copyright © 2018 RelativeView - Jae Yeum. All rights reserved.
//

import UIKit

/// **RelativeView** is a **UIKit** extension for **UIView**, providing methods/operations dedicated to finding other **UIViews** relatively.
extension UIView {
    
    /// Determines whether this **UIView** is a relative sibling of the given **UIView**. A **UIView** foo can only be the relative sibling of a
    /// **UIView** bar if foo !== bar, foo.superview === bar.superview (they share the same **superview**) and that **superview** is non-nil.
    /// - parameter view: The **UIView** that this **UIView** is potentially the relative sibling of.
    /// - returns: True if this **UIView** is the relative sibling of the given **view**, false if otherwise (if the **UIViews** do not share the
    /// same **superview** or the **superview** is nil).
    public func isRelativeSibling(of view: UIView) -> Bool {
        guard self !== view, let selfSuperview: UIView = self.superview, let viewSuperview: UIView = view.superview, selfSuperview === viewSuperview else {
            return false
        }
        return true
    }
    
    /// Traverses the **subviews** of the given **view**, calling the given **traversal** closure on each **UIView**.
    /// - parameter view: The **UIView** to traverse by depth-first.
    /// - parameter traversal: The closure to call on each traversed **UIView**.
    private func traverseSubviews(for view: UIView, traversal: (UIView) -> Void) {
        for subview in view.subviews {
            traversal(subview)
        }
    }
    
    /// Groups sibling **UIViews** by the **Type** **key** returned by the **groupKey** closure.
    /// - note: This uses **subviews** so the order of the returned elements is relative to the order of **subviews**.
    /// - parameter groupKey: Called on each sibling, the closure takes in the sibling and returns a **Type** **key**. A non-nil **Type** key
    /// results in the sibling being grouped by that key. A nil **Type** key results in the sibling not being grouped.
    /// - returns: The **Dictionary** of **Type** keys to an **Array** of **UIViews**. Each **Array** constitutes a group of **UIViews**. This returns
    /// an empty **Dictionary** if there are no groups or we exhaust the siblings, without grouping anything (this never returns nil).
    public func groupSiblings<Type: Hashable>(by groupKey: (UIView) -> Type?) -> [Type : [UIView]] {
        // First make sure that self can even have siblings (by having a superview).
        guard let selfSuperview: UIView = self.superview else {
            return [:]
        }
        
        // Next traverse the subviews of the superview and check each if its a potential sibling.
        var groups: [Type : [UIView]] = [:]
        traverseSubviews(for: selfSuperview) {
            (sibling: UIView) -> Void in
            // Make sure each "sibling" is actually a sibling (the "sibling" must not be self), we only want to group the siblings of self.
            guard sibling !== self else {
                return
            }
            
            if let key: Type = groupKey(sibling) {
                // If a non-nil key is returned the traversed sibling must be grouped by it.
                var siblings: [UIView] = groups[key] ?? []
                siblings.append(sibling)
                groups[key] = siblings
            }
        }
        return groups
    }
    
    /// Groups sibling **UIViews** by the given **viewTypes**.
    /// - note: The key is the **String** representation of **UIView.Type**.
    /// - note: This uses **subviews** so the order of the returned elements is relative to the order of **subviews**.
    /// - parameter viewTypes: The **UIView.Type** to group by.
    /// - returns: The **Dictionary** of **String** keys to an **Array** of **UIViews**. The **String** keys represent the **Strings** describing the
    /// given **viewTypes**. Each **Array** constitutes a group of **UIViews**. This returns an empty **Dictionary** if there are no groups or we exhaust
    /// the siblings, without grouping anything (this never returns nil).
    public func groupSiblings(by viewTypes: [UIView.Type]) -> [String : [UIView]] {
        return groupSiblings() {
            (sibling: UIView) -> String? in
            for viewType in viewTypes {
                let siblingViewType: UIView.Type = type(of: sibling)
                if viewType == siblingViewType {
                    return String(describing: siblingViewType)
                }
            }
            return nil
        }
    }
    
    /// Groups sibling **UIViews** by the given **tags**.
    /// - note: This uses **subviews** so the order of the returned elements is relative to the order of **subviews**.
    /// - parameter tags: The **tag** of **UIView** to group by.
    /// - returns: The **Dictionary** of **Int** keys to an **Array** of **UIViews**. The **Int** keys represent the given **tags**. Each **Array**
    /// constitutes a group of **UIViews**. This returns an empty **Dictionary** if there are no groups or we exhaust the siblings, without grouping
    /// anything (this never returns nil).
    public func groupSiblings(by tags: [Int]) -> [Int : [UIView]] {
        return groupSiblings() {
            (sibling: UIView) -> Int? in
            for tag in tags {
                if tag == sibling.tag {
                    return tag
                }
            }
            return nil
        }
    }
        
}
