import SwiftUI

struct SplashScreenView: View {
    let opacity: Double
    
    var body: some View {
        ZStack {
            // Sfondo nero
            Color.black
                .ignoresSafeArea()
            
            // Logo al centro con fade out
            Image("icon_app_white.png")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .opacity(opacity)
        }
    }
}

#Preview {
    SplashScreenView(opacity: 1.0)
} 
