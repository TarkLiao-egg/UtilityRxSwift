import Foundation

struct TransactionPost: Codable {

    let time: Int
    let title: String
    let description: String
    let details: [TransactionDetail]
}

struct Transaction: Codable {

    let id: Int
    let time: Int
    let title: String
    let description: String
    var details: [TransactionDetail]?

    enum CodingKeys: String, CodingKey {
        case id, time, title, description, details
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        time = try values.decode(Int.self, forKey: .time)
        title = try values.decode(String.self, forKey: .title)
        description = try values.decode(String.self, forKey: .description)
        details = try? values.decode([TransactionDetail].self, forKey: .details)
    }
    
    init(id: Int, time: Int, title: String, description: String) {
        self.id = id
        self.time = time
        self.title = title
        self.description = description
        self.details = []
    }
}

struct TransactionDetail: Codable {
    let id: String
    let name: String
    let quantity: Int
    let price: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, quantity, price
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID().uuidString
        name = try values.decode(String.self, forKey: .name)
        quantity = try values.decode(Int.self, forKey: .quantity)
        price = try values.decode(Int.self, forKey: .price)
    }
    
    init(id: String = UUID().uuidString, name: String, quantity: Int, price: Int) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.price = price
    }
}
