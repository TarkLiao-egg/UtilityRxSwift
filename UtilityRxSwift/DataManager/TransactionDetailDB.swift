import Foundation

class TransactionDetailDB: SQLModel {
    var id: Int = -1
    var name: String
    var quantity: Int
    var price: Int
    var transaction_id: Int
    init(name:String, quantity: Int, price: Int, transaction_id: Int) {
        self.name = name
        self.quantity = quantity
        self.price = price
        self.transaction_id = transaction_id
    }
    
    required init() {
        self.name = ""
        self.quantity = -1
        self.price = -1
        self.transaction_id = -1
    }
}
