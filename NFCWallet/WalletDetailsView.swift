import SwiftUI

struct WalletDetailsView: View {
    let mnemonic: String

    var body: some View {
        VStack(spacing: 20) {
            Text("钱包详情")
                .font(.largeTitle)
                .padding()

            // 显示助记词
            Text("助记词: \(mnemonic)")
                .padding()

            // 确认并进入钱包主页按钮
            Button(action: {
                // 进入钱包主页
                print("进入钱包主页")
            }) {
                Text("进入钱包")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
