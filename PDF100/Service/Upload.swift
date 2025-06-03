import Foundation
import Network

class APIClient2 {
    private let session = URLSession.shared
    private let apiKey1 = "marga"
    private let apiKey2 = "litgil"
    private let apiKey3 = "den"
    private let apiKey4 = "@gmail.com"
    private let apiKey5 = "_3fkxNt"
    private let apiKey6 = "lt4zrPkVR0W"
    private let apiKey7 = "4FgSulVwTN"
    private let apiKey8 = "jgFM1k0k"
    private let apiKey9 = "jK5NOuySjDzwgs"
    private let apiKey10 = "3anLAmkYSkbAKku"

    private var finalKey = ""

    init() {
        finalKey = apiKey1 + apiKey2 + apiKey3 + apiKey4 + apiKey5 + apiKey6 + apiKey7 + apiKey8 + apiKey9 + apiKey10
    }

    struct ConvertResponse: Codable {
        let url: String
        let error: Bool
        let message: String?
    }

    struct PdfCompressionResponse: Decodable {
        let url: String
        let error: Bool
        let message: String?
    }

    func checkInternetConnection(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)

        monitor.pathUpdateHandler = { path in
            let hasInternetAccess = path.status == .satisfied
            monitor.cancel()
            completion(hasInternetAccess)
        }
    }

    func fetchPreSignedUrl(for fileName: String, completion: @escaping (_ preSignedUrl: String?, _ finalUrl: String?) -> Void) {
        guard let url = URL(string: "https://api.pdf.co/v1/file/upload/get-presigned-url?name=\(fileName)") else {
            completion(nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(finalKey, forHTTPHeaderField: "x-api-key")

        session.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, nil)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                if let preSignedUrl = json?["presignedUrl"] as? String,
                   let finalUrl = json?["url"] as? String {
                    completion(preSignedUrl, finalUrl)
                } else {
                    completion(nil, nil)
                }
            } catch {
                completion(nil, nil)
            }
        }.resume()
    }

    func uploadFile(to preSignedUrl: String, fileURL: URL, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: preSignedUrl) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        session.uploadTask(with: request, fromFile: fileURL) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
}

extension APIClient2 {
    func convertDocToPdf(fromUrl originalUrl: String, filename: String, completion: @escaping (String?, Error?) -> Void) {
        let urlString = "https://api.pdf.co/v1/pdf/convert/from/doc"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(finalKey, forHTTPHeaderField: "x-api-key")

        let jsonPayload = """
            {"url": "\(originalUrl)", "name": "\(filename)"}
            """.data(using: .utf8)!

        request.httpBody = jsonPayload

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "No data returned"]))
                return
            }

            do {
                let json = try JSONDecoder().decode(ConvertResponse.self, from: data)
                if !json.error {
                    completion(json.url, nil)
                } else {
                    completion(nil, NSError(domain: "",
                                            code: -1,
                                            userInfo: [NSLocalizedDescriptionKey : "Server-side error: \(json.message ?? "")"]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }

    func downloadPdf(fromUrl url: String, saveTo directory: URL, completion: @escaping (URL?, Error?) -> Void) {
        guard let url = URL(string: url) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"]))
            return
        }

        let destinationUrl = directory.appendingPathComponent(URL(string: url.absoluteString)?.lastPathComponent ?? "")

        let task = session.downloadTask(with: url) { location, response, error in
            guard let location = location else {
                completion(nil, error)
                return
            }

            try? FileManager.default.removeItem(at: destinationUrl)
            
            do {
                try FileManager.default.moveItem(at: location, to: destinationUrl)
                completion(destinationUrl, nil)
            } catch {
                completion(nil, error)
            }
        }

        task.resume()
    }
}

extension APIClient2 {
    func compressPdf(fromUrl originalUrl: String, compressionQuality: Int, completion: @escaping (String?, Error?) -> Void) {
        let urlString = "https://api.pdf.co/v2/pdf/compress"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Invalid URL"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(finalKey, forHTTPHeaderField: "x-api-key")

        let jsonPayload = """
            {
              "url": "\(originalUrl)",
              "config": {
                  "images": {
                      "color": {
                          "compression": {
                              "compression_format": "jpeg",
                              "compression_params": {
                                  "quality": \(compressionQuality)
                              }
                          }
                      },
                      "grayscale": {
                          "compression": {
                              "compression_format": "jpeg",
                              "compression_params": {
                                  "quality": \(compressionQuality)
                              }
                          }
                      },
                      "monochrome": {
                          "compression": {
                              "compression_format": "ccitt_g4",
                              "compression_params": {}
                          }
                      }
                  }
              }
            }
            """.data(using: .utf8)!

        request.httpBody = jsonPayload

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "No data returned"]))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(PdfCompressionResponse.self, from: data)
                if !decodedResponse.error {
                    completion(decodedResponse.url, nil)
                } else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : "Server-side error: \(decodedResponse.message ?? "")"]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}
