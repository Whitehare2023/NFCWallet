import SwiftUI
import WalletCore

struct WalletSetupView: View {
    @Binding var isWalletInitialized: Bool
    @Binding var mnemonic: String
    @State private var userMnemonic: String = ""
    @State private var showMnemonicInput = false // 控制助记词输入框显示
    @State private var isGenerating = false // 控制按钮显示状态

    var body: some View {
        VStack(spacing: 20) {
            Text("欢迎使用 NFCWallet")
                .font(.largeTitle)
                .padding()

            if showMnemonicInput || isGenerating {
                TextField("输入助记词", text: $userMnemonic)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }

            if !showMnemonicInput && !isGenerating {
                Button(action: {
                    // 生成新的助记词
                    if let wallet = HDWallet(strength: 128, passphrase: "") {
                        mnemonic = wallet.mnemonic
                        isGenerating = true // 隐藏其他按钮，显示助记词输入框
                        userMnemonic = mnemonic
                    } else {
                        print("无法生成助记词")
                    }
                }) {
                    Text("生成助记词")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: {
                    // 点击后显示助记词输入框
                    showMnemonicInput = true
                }) {
                    Text("导入助记词")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }

            if showMnemonicInput || isGenerating {
                Button(action: {
                    // 验证输入的助记词并导入
                    if Mnemonic.isValid(mnemonic: userMnemonic) {
                        mnemonic = userMnemonic
                        isWalletInitialized = true // 确保切换状态
                        print("助记词确认成功，切换到钱包主页") // 添加调试输出
                    } else {
                        print("无效的助记词")
                    }
                }) {
                    Text("确认助记词")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}
