import SwiftUI

struct ContentView: View {
    @State private var isWalletInitialized = false
    @State private var mnemonic: String = ""

    var body: some View {
        if isWalletInitialized {
            // 传递生成的助记词到 WalletHomeView
            WalletHomeView(mnemonic: mnemonic)
        } else {
            WalletSetupView(isWalletInitialized: $isWalletInitialized, mnemonic: $mnemonic)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
