//
//  Descendant.swift
//  RelativeView
//
//  Created by Jae Yeum on 9/17/18.
//  Copyright © 2018 RelativeView - Jae Yeum. All rights reserved.
//

import UIKit

/// **RelativeView** is a **UIKit** extension for **UIView**, providing methods/operations dedicated to finding other **UIViews** relatively.
extension UIView {
    
    /// Recursively traverses the subviews of the given **view** by depth-first, calling the given **traversal** closure at each **UIView**. This is a
    /// depth-first traversal using the call stack as the stack (meaning this operates recursively, rather than iteratively).
    /// - parameter view: The **UIView** to traverse by depth-first.
    /// - parameter traversal: The closure to call on each traversed **UIView**, if false is returned traversal stops.
    /// - returns: True if traversal should continue, false otherwise.
    func depthFirstTraverse(_ view: UIView, traversal: (UIView) -> Bool) -> Bool {
        // For each subview do a recursive depth-first traversal.
        for subview in view.subviews {
            // Call the traversal closure on the subviews and stop traversal if the closure requests it.
            guard traversal(subview) else {
                return false
            }
            
            guard depthFirstTraverse(subview, traversal: traversal) else {
                // If an interrupt was requested, interrupt it.
                return false
            }
        }
        return true
    }
    
    /// Determines whether this **UIView** is a relative descendant of the given **UIView**. A **UIView** foo can only be the relative descendant of a
    /// **UIView** bar if foo !== bar.
    /// - note: This differs from **isDescendant(of:)** in that a **UIView** cannot be the descendant of itself (hence the qualifier "relative").
    /// - parameter view: The **UIView** that this **UIView** is potentially the relative descendant of.
    /// - returns: True if this **UIView** is the relative descendant of the given **view**, false if otherwise (or if the given **view** has no descendants).
    public func isRelativeDescendant(of view: UIView) -> Bool {
        // Make sure self is not the given view, otherwise it cannot be the relative descendant.
        guard self !== view else {
            return false
        }
        
        // Do a depth-first traversal of the descendancy, until we find that self is a descendant of the given view. If so return false which signals
        // an interrupt occurred (which can only occur in this case if a descendant is found).
        let isDescendant: Bool = !depthFirstTraverse(view) {
            (descendant: UIView) -> Bool in
            if descendant === self {
                return false
            }
            return true
        }
        
        // By this point return whether self is the relative descendant of the given view.
        return isDescendant
    }
    
    /// Groups descendant **UIViews** by the **Type** **key** returned by the **groupKey** closure.
    /// - note: This uses **subviews** so the order of the returned elements is relative to the order of **subviews**.
    /// - parameter groupKey: Called on each descendant, the closure takes in the descendant and returns a **Type** **key**. A non-nil **Type** key
    /// results in the descendant being grouped by that key. A nil **Type** key results in the descendant not being grouped.
    /// - returns: The **Dictionary** of **Type** keys to an **Array** of **UIViews**. Each **Array** constitutes a group of **UIViews**. This returns
    /// an empty **Dictionary** if there are no groups or we exhaust the descendancy, without grouping anything (this never returns nil).
    public func groupDescendants<Type: Hashable>(by groupKey: (UIView) -> Type?) -> [Type : [UIView]] {
        var groups: [Type : [UIView]] = [:]
        let _: Bool = depthFirstTraverse(self) {
            (descendant: UIView) -> Bool in
            if let key: Type = groupKey(descendant) {
                // If a non-nil key is returned the traversed descendant must be grouped by it.
                var descendants: [UIView] = groups[key] ?? []
                descendants.append(descendant)
                groups[key] = descendants
            }
            // Always traverse the next descendant.
            return true
        }
        return groups
    }
    
    /// Groups descendant **UIViews** by the given **viewTypes**.
    /// - note: The key is the **String** representation of **UIView.Type**.
    /// - note: This uses **subviews** so the order of the returned elements is relative to the order of **subviews**.
    /// - parameter viewTypes: The **UIView.Type** to group by.
    /// - returns: The **Dictionary** of **String** keys to an **Array** of **UIViews**. The **String** keys represent the **Strings** describing the
    /// given **viewTypes**. Each **Array** constitutes a group of **UIViews**. This returns an empty **Dictionary** if there are no groups or we exhaust
    /// the descendancy, without grouping anything (this never returns nil).
    public func groupDescendants(by viewTypes: [UIView.Type]) -> [String : [UIView]] {
        return groupDescendants() {
            (descendant: UIView) -> String? in
            for viewType in viewTypes {
                let descendantViewType: UIView.Type = type(of: descendant)
                if viewType == descendantViewType {
                    return String(describing: descendantViewType)
                }
            }
            return nil
        }
    }
    
    /// Groups descendant **UIViews** by the given **tags**.
    /// - note: This uses **subviews** so the order of the returned elements is relative to the order of **subviews**.
    /// - parameter tags: The **tag** of **UIView** to group by.
    /// - returns: The **Dictionary** of **Int** keys to an **Array** of **UIViews**. The **Int** keys represent the given **tags**. Each **Array**
    /// constitutes a group of **UIViews**. This returns an empty **Dictionary** if there are no groups or we exhaust the descendancy, without grouping
    /// anything (this never returns nil).
    public func groupDescendants(by tags: [Int]) -> [Int : [UIView]] {
        return groupDescendants() {
            (descendant: UIView) -> Int? in
            for tag in tags {
                if tag == descendant.tag {
                    return tag
                }
            }
            return nil
        }
    }
    
}
