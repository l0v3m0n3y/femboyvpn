import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.unknown))
                }
            }
            task.resume()
        }
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public class femboyVpn {
    private let api = "https://femboyvpn.connecto.lol/v1"
    private var headers: [String: String]
    
    public init() {
        self.headers = [
            "Connection": "keep-alive",
            "Accept-Encoding": "deflate, zstd",
            "Accept-Language": "en-US,en;q=0.9",
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36"
        ]
    }
    
    private func fetchJSON(from urlString: String, method: HTTPMethod = .get, body: Data? = nil, queryParameters: [String: String]? = nil) async throws -> Any {
        var urlComponents = URLComponents(string: urlString)
        if let queryParameters = queryParameters {
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = urlComponents?.url else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            updateHeaders(with: httpResponse, for: url)
        }
        
        return try JSONSerialization.jsonObject(with: data)
    }
    
    private func updateHeaders(with response: HTTPURLResponse, for url: URL) {
        guard let fields = response.allHeaderFields as? [String: String] else { return }
        
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
        
        if !cookies.isEmpty {
            let cookieString = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            self.headers["Cookie"] = cookieString
        }
    }
    
    public func getCode(email: String, password: String) async throws -> Any {
        let body: [String: Any] = ["email": email, "password": password]
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return try await fetchJSON(
            from: "\(api)/auth/register",
            method: .post,
            body: bodyData
        )
    }
    
    public func register(email: String, code: String) async throws -> Any {
        let body: [String: Any] = ["email": email, "code": code]
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let response = try await fetchJSON(
            from: "\(api)/auth/email/verify",
            method: .post,
            body: bodyData
        )
        
        if let dict = response as? [String: Any],
           let token = dict["csrf_token"] as? String {
            headers["x-csrf-token"] = token
        }

        return response
    }
    
    public func login(email: String, password: String) async throws -> Any {
        let body: [String: Any] = ["email": email, "password": password]
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let response = try await fetchJSON(
            from: "\(api)/auth/login",
            method: .post,
            body: bodyData
        )
        
        if let dict = response as? [String: Any],
           let token = dict["csrf_token"] as? String {
            headers["x-csrf-token"] = token
        }

        return response
    }
    
    public func getQuoteForBuy(months: Int,devices: Int) async throws -> Any {
        let body: [String: Any] = ["months": String(months),"devices": String(devices)]
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return try await fetchJSON(
            from: "\(api)/me/subscription-quotes",
            method: .post,
            body: bodyData
        )
    }
    
    public func logout() async throws -> Any {
        let body: [String: Any] = [:]
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let request = try await fetchJSON(
            from: "\(api)/auth/logout",
            method: .post,
            body: bodyData
        )

        self.headers.removeValue(forKey: "Cookie")
        
        self.headers.removeValue(forKey: "x-csrf-token")
        
        return request
    }
    
    public func confirmBuy(quoteId: String) async throws -> Any {
        let body: [String: Any] = [:]
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return try await fetchJSON(
            from: "\(api)/me/subscription-quotes/\(quoteId)/confirm",
            method: .post,
            body: bodyData
        )
    }


    public func startPayments(amount: String,method: String) async throws -> Any {
        let body: [String: Any] = ["amount": amount,"method": method]
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return try await fetchJSON(
            from: "\(api)/me/payments",
            method: .post,
            body: bodyData
        )
    }
    
    public func checkOperation(operationId: String) async throws -> Any {
        return try await fetchJSON(from: "\(api)/operations/\(operationId)")
    }
    
    public func getPaymentMethods() async throws -> Any {
        return try await fetchJSON(from: "\(api)/me/payment-methods")
    }
    
    public func getTarifs() async throws -> Any {
        return try await fetchJSON(from: "\(api)/public/tariffs")
    }
}
