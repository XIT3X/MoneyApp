import SwiftUI

// Estensione per bloccare l'orientamento a portrait
extension View {
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) -> some View {
        self.onAppear {
            AppDelegate.orientationLock = orientation
        }
    }
}

// Classe per gestire il delegate dell'app
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configura lo splash screen
        if let windowScene = application.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.backgroundColor = .black
        }
        return true
    }
} 