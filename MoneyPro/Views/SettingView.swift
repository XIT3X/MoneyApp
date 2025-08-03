import SwiftUI
import StoreKit

struct SettingView: View {
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    @StateObject private var settingsManager = SettingsManager()
    @State private var notificationsEnabled = true
    
    // MARK: - Computed Properties
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    

    
    var body: some View {
        ZStack {
            Colors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView

                VStack(spacing: 0) {
                    // Sezione App
                    settingsSection(title: "Generali") {
                        // Notifiche
                        settingsRow(
                            icon: "ic_notifications",
                            title: "Notifiche",
                            showSwitch: true,
                            isOn: $notificationsEnabled
                        ) {
                            // Toggle notifications
                            notificationsEnabled.toggle()
                        }
                        .padding(.bottom, -5)
                    }
                    .padding(.bottom, 10)
                    
                    // Sezione Supporto
                    settingsSection(title: "Supporto") {
                        // Segnala un Bug
                        settingsRow(
                            icon: "ic_bug",
                            title: "Segnala un Bug",
                            showSwitch: false
                        ) {
                            reportBug()
                        }
                        
                        // Vota su App Store
                        settingsRow(
                            icon: "ic_star",
                            title: "Vota su App Store",
                            showSwitch: false
                        ) {
                            rateOnAppStore()
                        }
                        
                        // Condividi l'App
                        settingsRow(
                            icon: "ic_share",
                            title: "Condividi l'App",
                            showSwitch: false
                        ) {
                            shareApp()
                        }
                    }
                    
                    .padding(.bottom, 10)
                    // Sezione Social
                    settingsSection(title: "Social") {
                        // Segui su Instagram
                        settingsRow(
                            icon: "ic_instagram",
                            title: "Segui su Instagram",
                            showSwitch: false
                        ) {
                            followOnInstagram()
                        }
                    }
                    
                    Spacer()
                    
                    // Footer con nome app e versione
                    VStack(spacing: 4) {
                        Text("Money Pro")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Colors.primaryText)
                        
                        Text("Versione \(appVersion)")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Colors.secondaryText)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.top, 10)
            }
        }
        .onAppear {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 0) {
            // Header con pulsanti
            HStack {
                // Tasto X per chiudere
                Button(action: { 
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Colors.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(Colors.primaryBackground)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
                
                Spacer()
                // Titolo Impostazioni
                HStack(spacing: 0) {
                    Text("Impostazioni")
                        .font(AppFonts.headline)
                        .foregroundColor(Colors.primaryText)
                }
                .padding(.trailing, 44)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 5) // Spazio sopra ridotto a 5 punti
    }
    
    // MARK: - Settings Section
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Colors.secondaryText)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 15)
            
            // Divider
            Rectangle()
                .fill(Colors.outlineColor)
                .frame(height: 1)
                .padding(.horizontal, 30)
                .padding(.top, 8)
            
            // Section content
            content()
        }
    }
    
    // MARK: - Settings Row
    private func settingsRow(
        icon: String,
        title: String,
        showSwitch: Bool,
        isOn: Binding<Bool>? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Titolo
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(Colors.primaryText)
                
                Spacer()
                
                // Switch o freccia
                if showSwitch, let isOn = isOn {
                    Toggle("", isOn: isOn)
                        .toggleStyle(SwitchToggleStyle(tint: Colors.primaryColor))
                        .labelsHidden()
                        .scaleEffect(0.8)
                        .padding(.trailing, -6)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Colors.secondaryText)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            .padding(.bottom, 8)
            .background(Colors.primaryBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Actions
    private func reportBug() {
        let email = "marcocomizzoli2002@gmail.com"
        let subject = "Segnalazione di un Bug"
        let mailtoString = "mailto:\(email)?subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: mailtoString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateOnAppStore() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func shareApp() {
        let appStoreURL = "https://apps.apple.com/it/app/money-pro/id6749245723"
        let shareText = "Scarica Money Pro - L'app per gestire le tue finanze in modo semplice e intuitivo! \(appStoreURL)"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // Per iPad, dobbiamo impostare il popover presentation
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // Presentazione più robusta per SwiftUI modals
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                
                // Cerca il view controller più in alto nella gerarchia
                var topViewController = window.rootViewController
                while let presentedViewController = topViewController?.presentedViewController {
                    topViewController = presentedViewController
                }
                
                // Presenta il share sheet
                topViewController?.present(activityVC, animated: true)
            }
        }
    }
    
    private func followOnInstagram() {
        let instagramURL = "https://www.instagram.com/marcocomizzolii"
        if let url = URL(string: instagramURL) {
            UIApplication.shared.open(url)
        }
    }
    

}


#if DEBUG
#Preview {
    SettingView(isPresented: .constant(true), onDismiss: {})
}
#endif 
