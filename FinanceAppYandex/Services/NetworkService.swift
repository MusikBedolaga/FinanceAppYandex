import Foundation

enum NetworkClientError: Error {
    case invalidURL
    case httpError(statusCode: Int, data: Data?)
    case encodingError(Error)
    case decodingError(Error)
    case transportError(Error)
    case missingData
}

actor NetworkService {
    
    let baseURL: URL
    private let token: String
    private let session: URLSession
    
    init(baseURL: URL, token: String, session: URLSession) {
        self.baseURL = baseURL
        self.token = token
        self.session = session
    }
    
    
    // MARK: - private request
    
    //MARK: Post Put Patch
    func request<Request: Encodable & Sendable, Response: Decodable & Sendable>(
        endpoint: String,
        method: String,
        body: Request,
        headers: [String: String] = [:]
    ) async throws -> Response {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw NetworkClientError.invalidURL
        }
        var request = createRequest(url: url, method: method, headers: headers)

        // Логируем и сериализуем body
        do {
            let encodedBody = try await Task(priority: .background) {
                try JSONEncoder().encode(body)
            }.value
            if let jsonString = String(data: encodedBody, encoding: .utf8) {
                print("REQUEST BODY JSON:", jsonString)
            }
            request.httpBody = encodedBody
        } catch {
            throw NetworkClientError.encodingError(error)
        }

        print("REQUEST: \(method) \(url.absoluteString)")
        print("HEADERS:", request.allHTTPHeaderFields ?? [:])

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkClientError.transportError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkClientError.missingData
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkClientError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        return try await decode(Response.self, from: data)
    }


    
    //MARK: Get Delete
    func request<Response: Decodable & Sendable>(
          endpoint: String,
          method: String = "GET",
          headers: [String: String] = [:]
      ) async throws -> Response {
          guard let url = buildURL(endpoint: endpoint) else {
              throw NetworkClientError.invalidURL
          }

          let request = createRequest(
              url: url,
              method: method,
              headers: headers
          )
          
          let (data, response): (Data, URLResponse)
          do {
              (data, response) = try await session.data(for: request)
          } catch {
              throw NetworkClientError.transportError(error)
          }

          guard let httpResponse = response as? HTTPURLResponse else {
              throw NetworkClientError.missingData
          }
          guard 200..<300 ~= httpResponse.statusCode else {
              throw NetworkClientError.httpError(statusCode: httpResponse.statusCode, data: data)
          }

          return try await decode(Response.self, from: data)
      }

    
    //MARK: - private
    private func buildURL(endpoint: String) -> URL? {
        let cleanEndpoint = endpoint.hasPrefix("/") ? String(endpoint.dropFirst()) : endpoint
        return URL(string: cleanEndpoint, relativeTo: baseURL)
    }
    
    private func createRequest(
        url: URL,
        method: String,
        headers: [String: String]
    ) -> URLRequest {
        var request = URLRequest(url: url)
        
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    private func decode<Response: Decodable & Sendable>(_ type: Response.Type, from data: Data) async throws -> Response {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                let formatter1 = ISO8601DateFormatter()
                formatter1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let formatter2 = ISO8601DateFormatter()
                formatter2.formatOptions = [.withInternetDateTime]
                
                if let date = formatter1.date(from: dateString) {
                    return date
                }
                if let date = formatter2.date(from: dateString) {
                    return date
                }
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string: \(dateString)"
                )
            }

            return try await Task(priority: .background) {
                try decoder.decode(Response.self, from: data)
            }.value
        } catch {
            throw NetworkClientError.decodingError(error)
        }
    }
}
