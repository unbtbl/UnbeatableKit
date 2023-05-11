import UIKit

extension UIViewController {
    /// Returns the view controller currently visible on the screen.
    public static var topMost: UIViewController? {
        guard var topController = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController }).first else {
            return nil
        }
        
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }
        
        return topController
    }
}

