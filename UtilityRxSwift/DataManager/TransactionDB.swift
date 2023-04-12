import Foundation
import UIKit

class TransactionDB: SQLModel {
    var id: Int = -1
    var time: Int
    var title: String
    var descriptionStr: String
    var imgKey: String
    
    init(time:Int, title: String, description: String) {
        self.time = time
        self.title = title
        self.descriptionStr = description
        self.imgKey = UUID().uuidString
    }
    
    required init() {
        self.time = -1
        self.title = ""
        self.descriptionStr = ""
        self.imgKey = ""
    }
    
    override func primaryKey() -> String {
        return "id"
    }
    
    override func ignoredKeys() -> [String] {
        return []
    }
}

extension TransactionDB {
    func saveImage(img: UIImage?) {
        guard let data = img?.jpegData(compressionQuality: 0.5) else { return }
        let encoded = try! PropertyListEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: imgKey)
    }

    func loadImage() -> UIImage? {
         guard let data = UserDefaults.standard.data(forKey: imgKey) else { return nil }
         let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
         return UIImage(data: decoded)
    }
}
