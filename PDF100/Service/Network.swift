import Foundation

struct UploadResponse: Codable {
    let presignedUrl: String
    let url: String
    let error: Bool
    let status: Int
    let remainingCredits: Int
}

class APIClient {
    static let shared = APIClient()
    private init() {}

    private let session = URLSession(configuration: .default)
    private let baseURL = "https://api.pdf.co/"
    private let apiKey = "YOUR_API_KEY_HERE"

    // Шаг 1: Получение предварительно подписанного URL
    func getPresignedUrl(for filename: String, completion: @escaping (Result<(presignedUrl: String, url: String), Error>) -> Void) {
        var urlComponents = URLComponents(string: "$baseURL)v1/file/upload/get-presigned-url")!
        urlComponents.queryItems = []
        urlComponents.queryItems?.append(URLQueryItem(name: "name", value: filename))



        guard let url = urlComponents?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let task = session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Empty Data", code: -2, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(UploadResponse.self, from: data)

                if response.error || response.status != 200 {
                    completion(.failure(NSError(domain: "Server returned error", code: response.status, userInfo: nil)))
                    return
                }

                completion(.success((response.presignedUrl, response.url)))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    // Шаг 2: Отправка файла на предварительно подписанный URL
    func uploadFile(filename: String, fileURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        getPresignedUrl(for: filename) { result in
            switch result {
            case .success(let (presignedUrl, _)) :
                var request = URLRequest(url: URL(string: presignedUrl)!)
                request.httpMethod = "PUT"
                request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

                let task = self.session.uploadTask(with: request, fromFile: fileURL) { data, response, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        completion(.failure(NSError(domain: "Failed to upload file", code: -3, userInfo: nil)))
                        return
                    }

                    completion(.success(()))
                }

                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// Пример использования:
//let client = APIClient.shared
//client.uploadFile(filename: "myfile.doc", fileURL: URL(fileURLWithPath: "/path/to/myfile.doc")) { result in
//    switch result {
//    case .success():
//        print("Файл успешно загружен!")
//    case .failure(let error):
//        print("Ошибка при загрузке файла: $error.localizedDescription)")
//    }
//}
