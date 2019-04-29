Pod::Spec.new do |s|
  s.name         = "relative-view"
  s.version      = "1.0.2"
  s.summary      = "A UIKit extension for UIView providing methods/operations dedicated to finding other UIViews relatively."
  s.description  = <<-DESC
	RelativeView is a UIKit extension for UIView providing methods/operations dedicated to finding other UIViews relatively.
	It offers operations to find and group ancestor (parent), descendant (child) and sibling UIViews. There are also operations
	to determine whether a UIView is the ancestor, descendant or sibling of another UIView.
                   DESC
  s.homepage     = "https://github.com/JYSWDV/relative-view"
  s.license      = { :type => "GNU GPLv3", :file => "LICENSE.md" }
  s.author       = "Jae Yeum"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/JYSWDV/relative-view.git", :tag => "1.0.2" }
  s.source_files  = "RelativeView/*.swift"
  s.requires_arc = true
  s.swift_version = "5.0"
end
