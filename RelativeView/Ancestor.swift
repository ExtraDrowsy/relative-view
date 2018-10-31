//
//  Ancestor.swift
//  RelativeView
//
//  Created by Jae Yeum on 9/17/18.
//  Copyright © 2018 RelativeView - Jae Yeum. All rights reserved.
//

import UIKit

/// **RelativeView** is a **UIKit** extension for **UIView**, providing methods/operations dedicated to finding other **UIViews** relatively.
extension UIView {
    
    /// Finds the first **UIView** ancestor where the given **matches** closure returns true.
    /// - parameter matches: Called on each ancestor, the closure takes in the ancestor and returns a **Bool** indicating whether the ancestor matches.
    /// Use this to specify the criteria by which an ancestor matches.
    /// - returns: The optional **UIView** instance; this is non-nil if **matches** returns true for any ancestor, nil otherwise (nothing was found).
    public func findFirstAncestor(by matches: (UIView) -> Bool) -> UIView? {
        var currentAncestor: UIView? = self.superview
        while let ancestor: UIView = currentAncestor {
            if matches(ancestor) {
                return ancestor
            }
            currentAncestor = ancestor.superview
        }
        return nil
    }
    
    /// Finds the first **UIView** ancestor whose **UIView.Type** is in the given **viewTypes**.
    /// - parameter viewTypes: The **Types** of **UIView** to look for.
    /// - returns: The optional **UIView** instance found or nil if there were no **viewTypes** given or we reached the root without finding anything.
    public func findFirstAncestor(by viewTypes: [UIView.Type]) -> UIView? {
        return findFirstAncestor() {
            (ancestor: UIView) -> Bool in
            for viewType in viewTypes {
                if viewType == type(of: ancestor) {
                    return true
                }
            }
            return false
        }
    }
    
    /// Finds the first **UIView** ancestor whose **tag** is in the given **tags**.
    /// - parameter tags: The **Int** **tags** to look for.
    /// - returns: The optional **UIView** instance found or nil if there were no **tags** given or we reached the root without finding anything.
    public func findFirstAncestor(by tags: [Int]) -> UIView? {
        return findFirstAncestor() {
            (ancestor: UIView) -> Bool in
            return tags.contains(ancestor.tag)
        }
    }
    
    /// Determines whether this **UIView** is the relative ancestor of the given **UIView**. A **UIView** foo can only be the relative ancestor of a
    /// **UIView** bar if foo !== bar.
    /// - parameter view: The **UIView** that this **UIView** is potentially the relative ancestor of.
    /// - returns: True if this **UIView** is the relative ancestor of the given **view**, false if otherwise (or if the given **view** has no ancestors).
    public func isRelativeAncestor(of view: UIView) -> Bool {
        // Make sure self is not the given view, otherwise it cannot be the relative descendant.
        guard self !== view else {
            return false
        }

        // Find the first ancestor for the given view where the ancestor is self. If that exists then self is the relative ancestor of the given view.
        return view.findFirstAncestor() {
            (ancestor: UIView) -> Bool in
            return ancestor === self
        } != nil
    }
    
    /// Groups ancestor **UIViews** by the **Type** **key** returned by the **groupKey** closure.
    /// - parameter groupKey: Called on each ancestor, the closure takes in the ancestor and returns a **Type** **key**. A non-nil **Type** key
    /// results in the ancestor being grouped by that key. A nil **Type** key results in the ancestor not being grouped.
    /// - returns: The **Dictionary** of **Type** keys to an **Array** of **UIViews**. Each **Array** constitutes a group of **UIViews**. This returns
    /// an empty **Dictionary** if there are no groups or we reach the root of the ancestry, without grouping anything (this never returns nil).
    public func groupAncestors<Type: Hashable>(by groupKey: (UIView) -> Type?) -> [Type : [UIView]] {
        var groups: [Type : [UIView]] = [:]
        var currentAncestor: UIView? = superview
        while let ancestor: UIView = currentAncestor {
            if let key: Type = groupKey(ancestor) {
                // If a non-nil key is returned the ancestor must be grouped by it.
                if groups[key] != nil {
                    groups[key]!.append(ancestor)
                } else {
                    groups[key] = [ancestor]
                }
            }
            // Move to the next ancestor.
            currentAncestor = ancestor.superview
        }
        return groups
    }
    
    /// Groups ancestor **UIViews** by the given **viewTypes**.
    /// - note: The key is the **String** representation of **UIView.Type**.
    /// - parameter viewTypes: The **UIView.Type** to group by.
    /// - returns: The **Dictionary** of **String** keys to an **Array** of **UIViews**. The **String** keys represent the **Strings** describing the
    /// given **viewTypes**. Each **Array** constitutes a group of **UIViews**. This returns an empty **Dictionary** if there are no groups or we reach
    /// the root of the ancestry, without grouping anything (this never returns nil).
    public func groupAncestors(by viewTypes: [UIView.Type]) -> [String : [UIView]] {
        return groupAncestors() {
            (ancestor: UIView) -> String? in
            for viewType in viewTypes {
                let ancestorViewType: UIView.Type = type(of: ancestor)
                if viewType == ancestorViewType {
                    return String(describing: ancestorViewType)
                }
            }
            return nil
        }
    }
    
    /// Groups ancestor **UIViews** by the given **tags**.
    /// - parameter tags: The **tag** of **UIView** to group by.
    /// - returns: The **Dictionary** of **Int** keys to an **Array** of **UIViews**. The **Int** keys represent the given **tags**. Each **Array**
    /// constitutes a group of **UIViews**. This returns an empty **Dictionary** if there are no groups or we reach the root of the ancestry, without
    /// grouping anything (this never returns nil).
    public func groupAncestors(by tags: [Int]) -> [Int : [UIView]] {
        return groupAncestors() {
            (ancestor: UIView) -> Int? in
            if tags.contains(ancestor.tag) {
                return ancestor.tag
            }
            return nil
        }
    }
    
}
