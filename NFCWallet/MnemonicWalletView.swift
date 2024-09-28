import SwiftUI
import WalletCore
import SolanaSwift

struct MnemonicWalletView: View {
    
    @State private var mnemonic: String = ""
    @State private var solanaAddress: String = ""
    @State private var ethereumAddress: String = ""
    @State private var bitcoinAddress: String = ""
    @State private var polygonAddress: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("输入助记词")
                .font(.headline)
            
            TextField("助记词", text: $mnemonic)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Button(action: {
                importMnemonic(mnemonic: mnemonic)
                Task {
                    await generateSolanaAddress(mnemonic: mnemonic)
                }
            }) {
                Text("生成钱包地址")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Solana 地址: \(solanaAddress)")
                Text("Ethereum 地址: \(ethereumAddress)")
                Text("Bitcoin 地址: \(bitcoinAddress)")
                Text("Polygon 地址: \(polygonAddress)")
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
    
    // 导入助记词并生成各链的地址
    func importMnemonic(mnemonic: String) {
        if !Mnemonic.isValid(mnemonic: mnemonic) {
            print("无效的助记词")
            return
        }
        
        // 使用 guard let 解包 HDWallet
        guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else {
            print("助记词无效，无法生成钱包")
            return
        }
        
        // 生成以太坊地址
        let ethereumPrivateKey = wallet.getKeyForCoin(coin: .ethereum)
        let ethereumAddress = CoinType.ethereum.deriveAddress(privateKey: ethereumPrivateKey)
        self.ethereumAddress = ethereumAddress

        // 生成比特币地址
        let bitcoinPrivateKey = wallet.getKeyForCoin(coin: .bitcoin)
        let bitcoinAddress = CoinType.bitcoin.deriveAddress(privateKey: bitcoinPrivateKey)
        self.bitcoinAddress = bitcoinAddress

        // 生成 Polygon 地址
        let polygonPrivateKey = wallet.getKeyForCoin(coin: .polygon)
        let polygonAddress = CoinType.polygon.deriveAddress(privateKey: polygonPrivateKey)
        self.polygonAddress = polygonAddress
    }
    
    // 使用 SolanaSwift 生成 Solana 地址
    func generateSolanaAddress(mnemonic: String) async {
        let phrase = mnemonic.components(separatedBy: " ")
        
        // 修正为 phrase，并处理异步调用
        guard let solanaAccount = try? await KeyPair(phrase: phrase, network: .mainnetBeta) else {
            print("无法生成 Solana 账户")
            return
        }
        self.solanaAddress = solanaAccount.publicKey.base58EncodedString
        print("Solana 地址: \(self.solanaAddress)")
    }
}
