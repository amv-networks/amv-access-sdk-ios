import Foundation


extension URLSession {

    func dataTask<Model>(with request: URLRequest, completion: @escaping (Result<Model>) -> Void, modelParser: @escaping (Data) throws -> Model) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            // If the OS returned an error, return it
            if let error = error {
                return completion(.error(error))
            }

            // Extract the data (of the JSON)
            guard let data = data else {
                return completion(.error(Failure.invalidData))
            }

            do {
                let result = try modelParser(data)

                completion(.success(result))
            }
            catch {
                // If the JSON parsing failed, it could be an error-response
                guard let serverError = try? JSONDecoder().decode(ServerError.self, from: data) else {
                    // If it was NOT an error-response, return the original expected-response error
                    return completion(.error(error))
                }

                completion(.error(serverError))

            }
        }
    }
}
