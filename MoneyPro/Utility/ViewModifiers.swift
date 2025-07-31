// MARK: - Import
import SwiftUI
import UIKit

// MARK: - Shared View Modifiers

// Keyboard aware modifier for handling keyboard appearance
struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                    keyboardHeight = keyboardFrame.height
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
            }
    }
}

// Shake effect for validation feedback
struct ShakeEffect: GeometryEffect {
    var animatableData: Double
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 3 * sin(animatableData * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// Extension to hide keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Estensione per ottimizzare il rendering delle icone vettoriali
extension Image {
    /// Ottimizza il rendering delle icone vettoriali per prevenire problemi di qualità
    func optimizedVectorIcon() -> some View {
        self
            .renderingMode(.template)
            .interpolation(.high)
            .antialiased(true)
    }
    
    /// Applica ottimizzazioni specifiche per icone piccole
    func smallIconOptimized() -> some View {
        self
            .renderingMode(.template)
            .interpolation(.high)
            .antialiased(true)
            .imageScale(.medium)
    }
    
    /// Applica ottimizzazioni specifiche per icone grandi
    func largeIconOptimized() -> some View {
        self
            .renderingMode(.template)
            .interpolation(.high)
            .antialiased(true)
            .imageScale(.large)
    }
}

// Estensione per utilizzare i ViewModifier personalizzati
extension Image {
    func vectorIcon(size: CGFloat, color: Color) -> some View {
        self
            .renderingMode(.template)
            .interpolation(.high)
            .antialiased(true)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(color)
    }
    
    func vectorIconWithBackground(size: CGFloat, color: Color, backgroundColor: Color, cornerRadius: CGFloat = 12) -> some View {
        self
            .renderingMode(.template)
            .interpolation(.high)
            .antialiased(true)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(color)
            .frame(width: size + 8, height: size + 8)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
} 