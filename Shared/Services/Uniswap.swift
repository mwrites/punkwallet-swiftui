//
//  Uniswap.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/2.
//

import Foundation
import BigInt


class Uniswap: ObservableObject {
    @Published var pricesByToken: [String:Decimal] = [Token.placeholder.name:0]
    
    let subgraph = UniswapSubgraph()
    
    func getETHPrice() async throws {
        // can also used the contract version instead of the subgraph
        let price = try await subgraph.getETHPrice()
        await MainActor.run {
            pricesByToken[Token.placeholder.name] = price
        }
    }
}


class UniswapSubgraph {
    enum UniswapError: Error {
        case statusCode(Int)
        case parsingError(responseString: String)
    }
    
    func getETHPrice() async throws -> Decimal {
        let url = URL(string: Config.uniswapSubgraphUrl)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        // https://docs.uniswap.org/protocol/V2/reference/API/queries#pair-data
        // https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v2/graphql
        let query = """
        {
             pair(id: "\(Config.uniswapPairContract)"){
                 token0 {
                   id
                   symbol
                   name
                   derivedETH
                 }
                 token1 {
                   id
                   symbol
                   name
                   derivedETH
                 }
                 reserve0
                 reserve1
                 reserveUSD
                 trackedReserveETH
                 token0Price
                 token1Price
                 volumeUSD
                 txCount
             }
        }
        """
        
        let json = ["query": query]
        let payload = try JSONSerialization.data(withJSONObject: json)
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: payload)
        let httpResp = response as! HTTPURLResponse
        
        guard self.validate(statusCode: httpResp.statusCode) else {
            throw UniswapError.statusCode(httpResp.statusCode)
        }
        
        guard
            let json = try JSONSerialization.jsonObject(with: data) as? NSDictionary,
            let jsonRoot = json["data"] as? NSDictionary,
            let pair = jsonRoot["pair"] as? NSDictionary,
            let token0PriceStr = pair["token0Price"] as? String,
            let token0Price = Decimal(string: token0PriceStr)
        else {
            throw UniswapError.parsingError(responseString: String(data: data, encoding: .utf8)!)
        }
        return token0Price
    }
    
    func validate(statusCode: Int) -> Bool {
        return 200..<400 ~= statusCode
    }
}

class UniswapContracts {
//    func getPairFromDex() async throws -> String {
//        //    https://gist.github.com/monokh/5dc494b9fb7887ac02d6898b6458648c
//        //    https://github.com/Uniswap/docs/blob/9ccc01d51d7a8f3138573ca33990e9b7f1c62549/SDK_versioned_docs/version-2.0.0/guides/04-trading.md
//        //    Also this maybe: https://github.com/horizontalsystems/ethereum-kit-ios/blob/master/Example/EthereumKit/Configuration.swift
//    }
    
    
    
//    func getPrice() async throws {
//        try await uniswap.getPair()
        
//        Erc20Token(name: "DAI",       coin: "DAI",  contractAddress: try! Address(hex: "0x6b175474e89094c44da98b954eedeac495271d0f"), decimal: 18),
//        Erc20Token(name: "USD Coin",  coin: "USDC", contractAddress: try! Address(hex: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"), decimal: 6),
//        let function = GetToken0()
//        let response = try await function.call(withClient: self.client, responseType: GetReserves.Response.self)
//        print(response)
//        XCTAssertEqual(response.value, [EthereumAddress("0x44fe11c90d2bcbc8267a0e56d55235ddc2b96c4f")])
//    }
}

//struct GetReserves: ABIFunction {
//    // 'function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast)',
//    //
//    // REQUEST:
//    // data": "0x0902f1ac"
//    // RESPONSE:
//    // {
//    //   "jsonrpc": "2.0",
//    //   "id": 42,
//    //   "result": "0x00000000000000000000000000000000000000000008eae25b1b1700ec6fdb390000000000000000000000000000000000000000000000d3c679d7118ddb44c400000000000000000000000000000000000000000000000000000000626e9cb7"
//    // }
//    static let name = "token0"
//    let contract = EthereumAddress("0xa478c2975ab1ea89e8196811f51a7b7ade33eb11")
//    // UniswapV2Pair Contract
//    // https://etherscan.io/address/0xa478c2975ab1ea89e8196811f51a7b7ade33eb11#code
//    
//    // Array? Tuple?
//    // (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast)
//    struct Response: ABIResponse {
//        static var types: [ABIType.Type] = [EthereumAddress.self]
//        let value: Bool
//
//        init?(values: [ABIDecoder.DecodedValue]) throws {
//            self.value = try values[0].decoded()
//        }
//    }
//    
//    var from: EthereumAddress? = nil
//    let gasPrice: BigUInt? = nil
//    let gasLimit: BigUInt? = nil
//    func encode(to encoder: ABIFunctionEncoder) throws {}
//}
//
//struct GetToken0: ABIFunction {
//    // const token0Address = await contract.token0()
//    // REQUEST:
//    // "data": "0x0dfe1681"
//    // "id": 42,
//    // RESPONSE:
//    // {
//    //   "jsonrpc": "2.0",
//    //   "id": 42,
//    //   "result": "0x0000000000000000000000006b175474e89094c44da98b954eedeac495271d0f"
//    // }
//
//    // const token1Address = await contract.token1()
//    // REQUEST:
//    // "data": "0xd21220a7"
//    // "id": 42,
//    // RESPONSE:
//    // {
//    //   "jsonrpc": "2.0",
//    //   "id": 42,
//    //   "result": "0x000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
//    // }
//    
//    // TODO what's id: 42?
//
////    'function token0() external view returns (address)',
////    'function token1() external view returns (address)
//    static let name = "token0"
//    let contract = EthereumAddress("0xa478c2975ab1ea89e8196811f51a7b7ade33eb11")
//    // UniswapV2Pair Contract
//    // https://etherscan.io/address/0xa478c2975ab1ea89e8196811f51a7b7ade33eb11#code
//    
//    struct Response: ABIResponse {
//        static var types: [ABIType.Type] = [EthereumAddress.self]
//        let value: Bool
//
//        init?(values: [ABIDecoder.DecodedValue]) throws {
//            self.value = try values[0].decoded()
//        }
//    }
//    
//    var from: EthereumAddress? = nil
//    let gasPrice: BigUInt? = nil
//    let gasLimit: BigUInt? = nil
//    func encode(to encoder: ABIFunctionEncoder) throws {}
//}
//}
