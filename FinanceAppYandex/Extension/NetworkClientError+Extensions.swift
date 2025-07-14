import Foundation

extension NetworkClientError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный URL запроса."
        case .httpError(let statusCode, _):
            if statusCode == 401 {
                return "Ошибка авторизации (401). Проверьте ваш токен!"
            } else if statusCode == 403 {
                return "Доступ запрещён (403). Нет прав для этого действия."
            } else if (400...499).contains(statusCode) {
                return "Ошибка клиента. Проверьте правильность введённых данных или попробуйте позже."
            } else if (500...599).contains(statusCode) {
                return "Ошибка сервера. Пожалуйста, попробуйте ещё раз позже."
            } else {
                return "Неизвестная ошибка (\(statusCode))."
            }
        case .encodingError:
            return "Ошибка при кодировании данных для отправки."
        case .decodingError:
            return "Ошибка при чтении ответа от сервера."
        case .transportError:
            return "Проблема с интернет-соединением."
        case .missingData:
            return "Сервер не вернул данные."
        }
    }
}

