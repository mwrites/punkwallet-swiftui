//
//  Contacts.swift
//  punkwallet
//
//  Created by mwrites on 2022/5/8.
//

import Foundation
import Combine
import web3


struct Contact: Codable, Hashable, Identifiable {
    var id = UUID()
    let ads: String
    var ens: String? = nil
}

extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.ads == rhs.ads
    }
}



class ContactsProvider: ObservableObject {
    @Published var recentContacts = [Contact]()
    
    @Published var isValidContact = false
    @Published var destAddress = EthereumAddress.zero
    @Published var destAddressTxt = "" {
        didSet {
            isValidAddrPublisher.send(destAddressTxt)
         }
    }
    
    @Published var isSearching = false
    
    private let isValidAddrPublisher = CurrentValueSubject<String, Never>("")
    
    init() {
        
//    https://peterfriese.dev/posts/swift-combine-love/
//    https://heckj.github.io/swiftui-notes/#pattern-observableobject
        isValidAddrPublisher
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .handleEvents(receiveOutput: { output in
                self.isSearching = true
            })
            .flatMap { value -> Future<Contact?, Never> in
                Future<Contact?, Never> { promise in
                    Task { [weak self] in
                        guard let lSelf = self else { return }
                        
                        guard !value.isEmpty else {
                            promise(.success(nil))
                            return
                        }
                        
                        // TOOD: handle error https://www.avanderlee.com/swift/combine-error-handling/
                        do {
                            let contact: Contact? = try await lSelf.resolveAddress(addrOrEns: value)
                            promise(.success(contact))
                        } catch {
                            print("error verifying addr \(value), \(error)")
                            promise(.success(nil))
                        }
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .handleEvents(receiveOutput: { contact in
                // TODO: duplicate work
                if let aContact = contact {
                    if !UserDefaults.standard.recentContacts.contains(aContact) {
                        UserDefaults.standard.recentContacts.append(aContact)
                    }
                }
                self.isSearching = false
            })
            .map {
                return $0 != nil
            }
            .assign(to: &$isValidContact)
    }
    
    func consumeQRCodeParserAddress(qrCodeParser: QRCodeParser) {
        guard !qrCodeParser.ethereumAddress.isEmpty else { return }
        destAddressTxt = qrCodeParser.ethereumAddress
        isValidContact = true
        qrCodeParser.ethereumAddress = ""
    }
    
    // https://betterprogramming.pub/search-bar-and-combine-in-swift-ui-46f37cec5a9f
    func getRecentContacts() {
        // TODO: implement me
//        let nMostUsedContracts = UserDefaults.standard.nMostUsedContacts
//        recentContacts = ["mwrites.eth"]
        recentContacts = UserDefaults.standard.recentContacts.reversed()
    }
    
//TODO: async await to combine https://medium.com/geekculture/from-combine-to-async-await-c08bf1d15b77
    func resolveAddress(addrOrEns: String) async throws -> Contact? {
        let knownContact = UserDefaults.standard.recentContacts.first {
            $0.ads == addrOrEns || $0.ens == addrOrEns
        }
        
        if let contact = knownContact {
            return contact
        }
        
        if addrOrEns.starts(with: "0x") {
            return Contact(ads: addrOrEns)
        } else {
            let ads = try await resolve(ens: addrOrEns)
            return !ads.value.isEmpty ? Contact(ads: ads.value, ens: addrOrEns): nil
        }
    }
    
    func resolve(ens: String) async throws -> EthereumAddress {
        let client = EthereumClient(url: URL(string: UserDefaults.standard.currentNetwork.url)!)
        let nameService = EthereumNameService(client: client)
        return try await nameService.resolve(ens: ens)
    }
}
