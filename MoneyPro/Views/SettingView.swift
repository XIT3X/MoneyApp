import SwiftUI

struct SettingView: View {
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    
    @StateObject private var backupService = BackupService.shared
    
    @State private var slideOffset: CGFloat = UIScreen.main.bounds.height
    @State private var isClosing = false
    @State private var showingBackupAlert = false
    @State private var showingRestoreAlert = false
    @State private var showingDeleteAlert = false
    @State private var backupMessage = ""
    
    var body: some View {
        ZStack {
            // Background overlay scuro
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissView()
                }
            
            // Contenuto principale
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    headerView
                    
                    // Area contenuto
                    VStack(spacing: 20) {
                        backupSection
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                }
                .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.8)
                .background(Color.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .offset(y: slideOffset)
            }
            .background(Color.white)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .background(Color.white)
        .onAppear {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            withAnimation(.easeOut(duration: 0.3)) {
                slideOffset = 0
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 0) {

            
            // Header con pulsanti
            HStack {
                // Tasto X a sinistra
                Button(action: { 
                    dismissView()
                }) {
                    Image(systemName: "xmark")
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
        .allowsHitTesting(true)
    }
    
    // MARK: - Backup Section
    private var backupSection: some View {
        VStack(spacing: 16) {
            Text("Backup e Ripristino")
                .font(AppFonts.headline)
                .foregroundColor(Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Backup Manuale
                Button(action: {
                    createManualBackup()
                }) {
                    HStack {
                        Image(systemName: "arrow.up.doc")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Colors.primaryText)
                        Text("Crea Backup")
                            .font(AppFonts.body)
                            .foregroundColor(Colors.primaryText)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Colors.secondaryBackground)
                    .cornerRadius(12)
                }
                
                // Ripristina Backup
                Button(action: {
                    showingRestoreAlert = true
                }) {
                    HStack {
                        Image(systemName: "arrow.down.doc")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Colors.primaryText)
                        Text("Ripristina Backup")
                            .font(AppFonts.body)
                            .foregroundColor(Colors.primaryText)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Colors.secondaryBackground)
                    .cornerRadius(12)
                }
                
                // Elimina Backup
                if backupService.hasBackup() {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Colors.errorText)
                            Text("Elimina Backup")
                                .font(AppFonts.body)
                                .foregroundColor(Colors.errorText)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Colors.error.opacity(0.3))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .alert("Backup Creato", isPresented: $showingBackupAlert) {
            Button("OK") { }
        } message: {
            Text(backupMessage)
        }
        .alert("Ripristina Backup", isPresented: $showingRestoreAlert) {
            Button("Annulla", role: .cancel) { }
            Button("Ripristina", role: .destructive) {
                restoreBackup()
            }
        } message: {
            Text("Sei sicuro di voler ripristinare il backup? Questa azione sovrascriverà tutti i dati attuali.")
        }
        .alert("Elimina Backup", isPresented: $showingDeleteAlert) {
            Button("Annulla", role: .cancel) { }
            Button("Elimina", role: .destructive) {
                deleteBackup()
            }
        } message: {
            Text("Sei sicuro di voler eliminare il backup? Questa azione non può essere annullata.")
        }
    }
    
    // MARK: - Backup Functions
    private func createManualBackup() {
        if let backupData = backupService.createManualBackup() {
            backupMessage = "Backup creato con successo! I tuoi dati sono ora salvati in modo sicuro."
            showingBackupAlert = true
        } else {
            backupMessage = "Errore nella creazione del backup. Riprova più tardi."
            showingBackupAlert = true
        }
    }
    
    private func restoreBackup() {
        if backupService.restoreFromAutomaticBackup() {
            backupMessage = "Backup ripristinato con successo!"
            showingBackupAlert = true
        } else {
            backupMessage = "Nessun backup trovato o errore nel ripristino."
            showingBackupAlert = true
        }
    }
    
    private func deleteBackup() {
        backupService.deleteBackup()
        backupMessage = "Backup eliminato con successo."
        showingBackupAlert = true
    }
    
    // MARK: - Dismiss
    private func dismissView() {
        // Prima chiama onDismiss per rendere visibile la pagina sottostante
        onDismiss()
        
        // Poi anima la chiusura
        withAnimation(.easeInOut(duration: 0.3)) {
            isClosing = true
            slideOffset = UIScreen.main.bounds.height
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#if DEBUG
#Preview {
    SettingView(isPresented: .constant(true), onDismiss: {})
}
#endif 
