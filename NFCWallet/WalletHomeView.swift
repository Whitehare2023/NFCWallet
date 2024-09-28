import SwiftUI
import WalletCore
import BigInt

struct WalletHomeView: View {
    let mnemonic: String
    @State private var ethereumBalance: String = "获取中..."
    @State private var solanaBalance: String = "获取中..."
    @State private var bitcoinBalance: String = "获取中..."
    @State private var polygonBalance: String = "获取中..."
    
    @State private var ethereumAddress: String = ""
    @State private var solanaAddress: String = ""
    @State private var bitcoinAddress: String = ""
    @State private var polygonAddress: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("NFCWallet")
                .font(.largeTitle)
                .padding()

            List {
                // Ethereum
                cardView(title: "Ethereum", address: ethereumAddress, balance: ethereumBalance, symbol: "ETH")

                // Polygon
                cardView(title: "Polygon", address: polygonAddress, balance: polygonBalance, symbol: "MATIC")

                // Solana
                cardView(title: "Solana", address: solanaAddress, balance: solanaBalance, symbol: "SOL")

                // Bitcoin
                cardView(title: "Bitcoin", address: bitcoinAddress, balance: bitcoinBalance, symbol: "BTC")
            }
            .listStyle(PlainListStyle()) // 简洁的列表样式
        }
        .padding()
        .onAppear {
            generateAddressesAndBalances()
        }
    }

    // 自定义卡片视图
    @ViewBuilder
    func cardView(title: String, address: String, balance: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(title): \(address)")
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text("\(symbol) 余额: \(balance)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemBackground)))
        .padding(.horizontal)
    }

    // 生成各个链的地址并获取余额
    func generateAddressesAndBalances() {
        if let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") {
            // Ethereum
            let ethereumPrivateKey = wallet.getKeyForCoin(coin: .ethereum)
            ethereumAddress = CoinType.ethereum.deriveAddress(privateKey: ethereumPrivateKey)
            fetchEthereumBalance(address: ethereumAddress)

            // Polygon
            let polygonPrivateKey = wallet.getKeyForCoin(coin: .polygon)
            polygonAddress = CoinType.polygon.deriveAddress(privateKey: polygonPrivateKey)
            fetchPolygonBalance(address: polygonAddress)

            // Solana
            let solanaPrivateKey = wallet.getKeyForCoin(coin: .solana)
            solanaAddress = CoinType.solana.deriveAddress(privateKey: solanaPrivateKey)
            fetchSolanaBalance(address: solanaAddress)

            // Bitcoin
            let bitcoinPrivateKey = wallet.getKeyForCoin(coin: .bitcoin)
            bitcoinAddress = CoinType.bitcoin.deriveAddress(privateKey: bitcoinPrivateKey)
            fetchBitcoinBalance(address: bitcoinAddress)
        }
    }

    // 获取以太坊余额（通过 Infura 获取）
    func fetchEthereumBalance(address: String) {
        let infuraUrl = "https://mainnet.infura.io/v3/93cfcb48f45f4a828d4aec2eb777b5d2"
        fetchBalance(url: infuraUrl, address: address, coinSymbol: "ETH") { balance in
            self.ethereumBalance = balance
        }
    }

    // 获取 Polygon 余额（通过 Infura 获取）
    func fetchPolygonBalance(address: String) {
        let infuraUrl = "https://polygon.llamarpc.com"
        fetchBalance(url: infuraUrl, address: address, coinSymbol: "MATIC") { balance in
            self.polygonBalance = balance
        }
    }

    // 获取 Solana 余额（通过 Solana RPC API）
    func fetchSolanaBalance(address: String) {
        let solanaUrl = "https://mainnet.helius-rpc.com/?api-key=306e91e8-2e51-407e-97a2-b49f5667f049"
        let url = URL(string: solanaUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Solana RPC 请求体，参数是一个包含地址的数组
        let json: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "getBalance",
            "params": [address],
            "id": 1
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Solana 请求失败: \(error.localizedDescription)")
                return
            }

            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let result = jsonResponse["result"] as? [String: Any],
                       let value = result["value"] as? Int {
                        // Solana 余额以 lamports 返回，需要除以 10^9 转换为 SOL
                        let balanceInSOL = Double(value) / pow(10, 9)
                        DispatchQueue.main.async {
                            solanaBalance = "\(balanceInSOL) SOL"
                        }
                    } else {
                        print("Solana 返回无效结果: \(jsonResponse)")
                    }
                } else {
                    print("无法解析 Solana 返回的数据")
                }
            }
        }
        task.resume()
    }


    // 获取比特币余额（通过 BlockCypher API）
    func fetchBitcoinBalance(address: String) {
        let bitcoinUrl = "https://api.blockcypher.com/v1/btc/main/addrs/\(address)/balance"
        let url = URL(string: bitcoinUrl)!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("请求失败: \(error)")
                return
            }

            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let balance = jsonResponse["final_balance"] as? Int {
                        let balanceInBTC = Double(balance) / pow(10, 8)
                        DispatchQueue.main.async {
                            bitcoinBalance = "\(balanceInBTC) BTC"
                        }
                    }
                }
            }
        }
        task.resume()
    }

    // 通用的余额查询函数（适用于 Ethereum 和 Polygon）
    func fetchBalance(url: String, address: String, coinSymbol: String, completion: @escaping (String) -> Void) {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let json: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_getBalance",
            "params": [address, "latest"],
            "id": 1
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("\(coinSymbol) 请求失败: \(error)")
                return
            }

            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let result = jsonResponse["result"] as? String {
                        let balanceInWei = BigInt(result.dropFirst(2), radix: 16) ?? 0
                        let balanceInEther = Double(balanceInWei) / pow(10, 18)
                        DispatchQueue.main.async {
                            completion("\(balanceInEther) \(coinSymbol)")
                        }
                    }
                }
            }
        }
        task.resume()
    }
}
