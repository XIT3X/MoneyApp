import SwiftUI

struct SettingView: View {
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
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
                    
                    // Segui su Instagram
                    settingsRow(
                        icon: "ic_instagram",
                        title: "Segui su Instagram",
                        showSwitch: false
                    ) {
                        followOnInstagram()
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
                .padding(.top, 20)
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
                // Tasto freccia a sinistra
                Button(action: { 
                    isPresented = false
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Colors.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(Colors.primaryBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Colors.outlineColor, lineWidth: 1)
                        )
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
        .padding(.top, 20)
        .padding(.bottom, 0)
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
                // Icona
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconBackgroundColor(for: icon))
                        .frame(width: 42, height: 42)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Colors.outlineColor, lineWidth: 1)
                        )
                    
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                }
                
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
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
        // Sostituisci con l'ID della tua app
        let appStoreURL = "https://apps.apple.com/app/id1234567890"
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareApp() {
        let appStoreURL = "https://apps.apple.com/app/id1234567890"
        let activityVC = UIActivityViewController(
            activityItems: [appStoreURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func followOnInstagram() {
        let instagramURL = "https://www.instagram.com/marcocomizzolii"
        if let url = URL(string: instagramURL) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Icon Colors
    private func iconBackgroundColor(for icon: String) -> Color {
        switch icon {
        case "ic_notifications":
            return Color(hex: "#489cfe") // Rosa scuro
        case "ic_bug":
            return Color(hex: "#f54c4c") // Corallo scuro
        case "ic_star":
            return Color(hex: "#faba22") // Giallo scuro
        case "ic_share":
            return Color(hex: "#5bca78") // Verde scuro
        case "ic_instagram":
            return Color(hex: "#9190a7") // Viola scuro
        default:
            return Colors.primaryBackground
        }
    }
}


#if DEBUG
#Preview {
    SettingView(isPresented: .constant(true), onDismiss: {})
}
#endif 
