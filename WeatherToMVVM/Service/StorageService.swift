import Foundation

protocol StorageServiceProtocol {
    func save<T: Encodable>(_ object: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T?
    func remove(forKey key: String)
}

class StorageService: StorageServiceProtocol {
    private let defaults = UserDefaults.standard
    
    func save<T: Encodable>(_ object: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            defaults.set(data, forKey: key)
        } catch {
            throw WeatherError.cacheError
        }
    }
    
    func load<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw WeatherError.decodingError
        }
    }
    
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}
