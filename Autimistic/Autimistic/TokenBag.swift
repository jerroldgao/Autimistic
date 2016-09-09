////
////  TokenBag.swift
////  Autimistic
////
////  Created by Darrall Flowers on 4/24/16.
////  Copyright © 2016 Darrall Flowers. All rights reserved.
////
//
//import Foundation
//
//
//enum Rank: Int, CustomStringConvertible {
//    case Ace = 1
//    case Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten
//    case Jack, Queen, King
//    var description: String {
//        switch self {
//        case .Ace:
//            return "ace"
//        case .Jack:
//            return "jack"
//        case .Queen:
//            return "queen"
//        case .King:
//            return "king"
//        default:
//            return String(self.rawValue)
//        }
//    }
//}
//
//
//struct Token: CustomStringConvertible, Equatable {
//    private let rank: Rank
// 
//    
//    var description: String {
//        return "\(rank.description)"
//    }
//}
//func ==(tokeni: Token, tokenk: Token) -> Bool {
//    return tokeni.rank == tokenk.rank
//}
//
//struct TokenBag {
//    private var tokens = [Token]()
//    
//    static func full() -> TokenBag {
//        var tokenbag = TokenBag()
//        for i in Rank.Ace.rawValue...Rank.King.rawValue {
//          
//                let token = Token(rank: Rank(rawValue: i)!)
//                tokenbag.append(token)
//                
//        }
//        return tokenbag
//    }
//    
//    
//
//    
//    func NumberOfTokens(num: Int) -> TokenBag {
//        return TokenBag(tokens: Array(tokens[0..<num]))
//    }
//    
//   
//    func shuffled() -> TokenBag {
//        let list = tokens
//        for i in 0..<(list.count - 1) {
//            _ = Int(arc4random_uniform(UInt32(list.count - i))) + i
//            
//        }
//        return TokenBag(tokens: list)
//    }
//}
//
//extension TokenBag {
//    private mutating func append(token: Token) {
//        tokens.append(token)
//    }
//    subscript(index: Int) -> Token {
//        get {
//            return tokens[index]
//        }
//    }
//    var cnt: Int {
//        get {
//            return tokens.count
//            
//        }
//    }
//    
//}
//
//func +(tokeni: TokenBag, tokenk: TokenBag) -> TokenBag {
//    return TokenBag(tokens: tokeni.tokens + tokenk.tokens)
//}
