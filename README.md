[![Build Status](https://travis-ci.com/JYSWDV/relative-view.svg?branch=master)](https://travis-ci.com/JYSWDV/relative-view)
[![codecov](https://codecov.io/gh/JYSWDV/relative-view/branch/master/graph/badge.svg?token=YN19MFFGWY)](https://codecov.io/gh/JYSWDV/relative-view)
# relative-view
`relative-view` is a `UIKit` extension for `UIView` providing methods/operations dedicated to finding other `UIViews` relatively. The goal of this framework is to provide a framework where:
- Users are allowed to find and group other `UIViews` in any manner they wish.
- The framework is fully unit tested (100% code coverage).

The term "relative" in this framework means a `UIView` cannot be the ancestor, descendant or sibling of itself. Relativity is also defined in an infinitely spanning manner, meaning this framework considers a `UIView` `foo` the ancestor, descendant or sibling of another `UIView` `bar`, even if there are any number of `UIViews` between them. Relativity is therefore not defined as `foo` and `bar` being directly adjacent to each other.

Here's a list of the methods/operations plus some examples showing the behavior.

---
- `findFirstAncestor(by: (UIView) -> Bool) -> UIView?`
With this overload you pass in a closure `(UIView) -> Bool`. This closure is called on every ancestor and must return `true` if the ancestor meets your criteria, the nearest ancestor that results in `true` is what is ultimately returned by this method.
- `findFirstAncestor(by: [UIView.Type]) -> UIView?`
With this overload the ancestors are evaluated using an `Array` of `UIView.Type`, the nearest ancestor with a `UIView.Type` in that `Array` is returned.
- `findFirstAncestor(by: [Int]) -> UIView?`
With this overload the ancestors are evaluated using an `Array` of `Int` representing `tags`, the nearest ancestor with a `tag` in that `Array` is returned.

Note that if more than one ancestor meets the condition in any of these overloads, the "first" (what is returned) is defined as the one nearest/proximal to `self` (the calling `UIView`).
```swift
let view: UIView = UIView(frame: CGRect())
view.tag = 3

let ancestor: UITableViewCell = UITableViewCell(frame: CGRect())
ancestor.tag = 1

ancestor.addSubview(view)

// Find the first ancestor by closure (you define how it finds ancestors!).
XCTAssertTrue(ancestor === view.findFirstAncestor() {
    (ancestor: UIView) -> Bool in
    return ancestor.tag == 1
})

// Find the first ancestor by UIView.Type.
XCTAssertTrue(ancestor === view.findFirstAncestor(by: [UITableViewCell.self]))

// Find the first ancestor by tag.
XCTAssertTrue(ancestor === view.findFirstAncestor(by: [1]))
```
---
- `isRelativeAncestor(of: UIView) -> Bool`
Checks whether the calling `UIView` is a relative ancestor of another `UIView`.

Note that a `UIView` `foo` can only be the relative ancestor of a `UIView` `bar` if `foo !== bar` (this is what the term "relative" means, a `UIView` cannot be the relative ancestor of itself).
```swift
let view: UIView = UIView(frame: CGRect())
let ancestor: UITableViewCell = UITableViewCell(frame: CGRect())
ancestor.addSubview(view)

// Checks whether ancestor is a relative ancestor of view.
XCTAssertTrue(ancestor.isRelativeAncestor(of: view))
```
---
- `groupAncestors<Type: Hashable>(by: (UIView) -> Type?) -> [Type : [UIView]]`
With this overload you define the type of the key to group on through generics. You also pass in a closure `(UIView) -> Type?`, this closure is called on all ancestors and must return a non-nil `Type` key if the ancestor is to be grouped by that key. A nil key returned signals the ancestor is not to be grouped.
- `groupAncestors(by: [UIView.Type]) -> [String : [UIView]]` 
With this overload you provide an `Array` of `UIView.Type`, ancestors are grouped only if their `UIView.Type` exists in that `Array` and the groups are keyed by the `String` describing `UIView.Type`.
- `groupAncestors(by: [Int]) -> [Int : [UIView]]`
With this overload you provide an `Array` of `Int` representing `tags`, ancestors are grouped only if their `tag` exists in that `Array` and the groups are keyed by the `tag`.

All of these operate the same, they return a `Dictionary` representing the groups of ancestors found relative to a `UIView`. They only differ in how the ancestors are found and grouped (by which type of key). In fact the latter two are just convenience methods for the first.
```swift
let view: UIView = UIView(frame: CGRect())
view.tag = 3

let ancestor: UITableViewCell = UITableViewCell(frame: CGRect())
ancestor.tag = 1

ancestor.addSubview(view)

// Group ancestors by closure (you define how it groups ancestors!).
let ancestorsByClosure: [Int : [UIView]] = view.groupAncestors() {
    (ancestor: UIView) -> Int? in
    if ancestor.tag == 1 {
        return ancestor.tag
    }
    return nil
}
XCTAssertEqual(1, ancestorsByClosure.count)
XCTAssertEqual(1, ancestorsByClosure[1]!.count)
XCTAssertTrue(ancestor === ancestorsByClosure[1]![0])

// Group ancestors by UIView.Type.
let tableViewCellKey: String = String(describing: UITableViewCell.self)
let ancestorsByViewType: [String : [UIView]] = view.groupAncestors(by: [UITableViewCell.self])
XCTAssertEqual(1, ancestorsByViewType.count)
XCTAssertEqual(1, ancestorsByViewType[tableViewCellKey]!.count)
XCTAssertTrue(ancestor === ancestorsByViewType[tableViewCellKey]![0])

// Group ancestors by tag.
let ancestorsByTag: [Int : [UIView]] = view.groupAncestors(by: [1])
XCTAssertEqual(1, ancestorsByTag.count)
XCTAssertEqual(1, ancestorsByTag[1]!.count)
XCTAssertTrue(ancestor === ancestorsByTag[1]![0])
```
---
- `isRelativeDescendant(of: UIView) -> Bool`
Checks whether the calling `UIView` is a relative descendant of another `UIView`.

Note that a `UIView` `foo` can only be the relative descendant of a `UIView` `bar` if `foo !== bar` (this is what the term "relative" means, a `UIView` cannot be the relative descendant of itself).

**_Descendancy is determined through depth-first traversal._**
```swift
let view: UIView = UIView(frame: CGRect())
let descendant: UITableViewCell = UITableViewCell(frame: CGRect())
view.addSubview(descendant)

// Checks whether descendant is a relative descendant of view.
XCTAssertTrue(descendant.isRelativeDescendant(of: view))
```
---
- `groupDescendants<Type: Hashable>(by: (UIView) -> Type?) -> [Type : [UIView]]`
With this overload you define the type of the key to group on through generics. You also pass in a closure `(UIView) -> Type?`, this closure is called on all descendants and must return a non-nil `Type` key if the descendant is to be grouped by that key. A nil key returned signals the descendant is not to be grouped.
- `groupDescendants(by: [UIView.Type]) -> [String : [UIView]]` 
With this overload you provide an `Array` of `UIView.Type`, descendants are grouped only if their `UIView.Type` exists in that `Array` and the groups are keyed by the `String` describing `UIView.Type`.
- `groupDescendants(by: [Int]) -> [Int : [UIView]]`
With this overload you provide an `Array` of `Int` representing `tags`, descendants are grouped only if their `tag` exists in that `Array` and the groups are keyed by the `tag`.

All of these operate the same, they return a `Dictionary` representing the groups of descendants found relative to a `UIView`. They only differ in how the descendants are found and grouped (by which type of key). In fact the latter two are just convenience methods for the first.

**_Descendancy is determined through depth-first traversal._**
```swift
let tableViewCell: UITableViewCell = UITableViewCell(frame: CGRect())
tableViewCell.tag = 3

let descendant: UIView = UIView(frame: CGRect())
descendant.tag = 1

tableViewCell.addSubview(descendant)

// Group descendants by closure (you define how it groups descendants!).
let descendantsByClosure: [Int : [UIView]] = tableViewCell.groupDescendants() {
    (descendant: UIView) -> Int? in
    if descendant.tag == 1 {
        return descendant.tag
    }
    return nil
}
XCTAssertEqual(1, descendantsByClosure.count)
XCTAssertEqual(1, descendantsByClosure[1]!.count)
XCTAssertTrue(descendant === descendantsByClosure[1]![0])
        
// Group descendants by UIView.Type.
let viewKey: String = String(describing: UIView.self)
let descendantsByViewType: [String : [UIView]] = tableViewCell.groupDescendants(by: [UIView.self])
XCTAssertEqual(1, descendantsByViewType.count)
XCTAssertEqual(1, descendantsByViewType[viewKey]!.count)
XCTAssertTrue(descendant === descendantsByViewType[viewKey]![0])

// Group descendants by tag.
let descendantsByTag: [Int : [UIView]] = tableViewCell.groupDescendants(by: [1])
XCTAssertEqual(1, descendantsByTag.count)
XCTAssertEqual(1, descendantsByTag[1]!.count)
XCTAssertTrue(descendant === descendantsByTag[1]![0])
```
---
- `isRelativeSibling(of: UIView) -> Bool`
Checks whether the calling `UIView` is a relative sibling of another `UIView`.

Note that a `UIView` `foo` can only be the relative sibling of a `UIView` `bar` if `foo !== bar` (this is what the term "relative" means, a `UIView` cannot be the relative descendant of itself), both `foo` and `bar` must have a non-nil `superview` and the non-nil `superview` for both must be the same.
```swift
let view: UIView = UIView()
let foo: UIButton = UIButton()
view.addSubview(foo)
let bar: UILabel = UILabel()
view.addSubview(bar)

// Checks whether foo is a relative sibling of bar (and vice-versa).
XCTAssertTrue(foo.isRelativeSibling(of: bar))
XCTAssertTrue(bar.isRelativeSibling(of: foo))
```
---
- `groupSiblings<Type: Hashable>(by: (UIView) -> Type?) -> [Type : [UIView]]`
With this overload you define the type of the key to group on through generics. You also pass in a closure `(UIView) -> Type?`, this closure is called on all siblings and must return a non-nil `Type` key if the sibling is to be grouped by that key. A nil key returned signals the sibling is not to be grouped.
- `groupSiblings(by: [UIView.Type]) -> [String : [UIView]]` 
With this overload you provide an `Array` of `UIView.Type`, siblings are grouped only if their `UIView.Type` exists in that `Array` and the groups are keyed by the `String` describing `UIView.Type`.
- `groupSiblings(by: [Int]) -> [Int : [UIView]]`
With this overload you provide an `Array` of `Int` representing `tags`, siblings are grouped only if their `tag` exists in that `Array` and the groups are keyed by the `tag`.

All of these operate the same, they return a `Dictionary` representing the groups of siblings found relative to a `UIView`. They only differ in how the siblings are found and grouped (by which type of key). In fact the latter two are just convenience methods for the first.
```swift
let view: UIView = UIView()
let foo: UIButton = UIButton()
foo.tag = 1
view.addSubview(foo)
let bar: UILabel = UILabel()
bar.tag = 2
view.addSubview(bar)

// Group siblings by closure (you define how it groups siblings!).
let siblingsByClosure: [Int : [UIView]] = bar.groupSiblings() {
    (sibling: UIView) -> Int? in
    if sibling.tag == 1 {
        return sibling.tag
    }
    return nil
}
XCTAssertEqual(1, siblingsByClosure.count)
XCTAssertEqual(1, siblingsByClosure[1]!.count)
XCTAssertTrue(foo === siblingsByClosure[1]![0])
        
// Group siblings by UIView.Type.
let buttonKey: String = String(describing: UIButton.self)
let siblingsByViewType: [String : [UIView]] = bar.groupSiblings(by: [UIButton.self])
XCTAssertEqual(1, siblingsByViewType.count)
XCTAssertEqual(1, siblingsByViewType[buttonKey]!.count)
XCTAssertTrue(foo === siblingsByViewType[buttonKey]![0])

// Group siblings by tag.
let siblingsByTag: [Int : [UIView]] = bar.groupSiblings(by: [1])
XCTAssertEqual(1, siblingsByTag.count)
XCTAssertEqual(1, siblingsByTag[1]!.count)
XCTAssertTrue(foo === siblingsByTag[1]![0])
```
