//
//  ServerManager.swift
//  ProjetosI
//
//  Created by Isaías Lima on 04/04/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import JASON

enum RequestStatus<T> {
    case success(T)
    case failure(Error)
}

class ServerManager {

    static var cache: [String : Any] = [:]
    static var user: User = User(username: "default", email: "default@default.com")

    private struct API {

        typealias DyURL = (String) -> String

        private init() {}

        static let base             = "https://projetos-eletronicos.herokuapp.com/"
        static let user: DyURL      = { return "\(base)user/\($0)/" }
        static let device: DyURL    = { return "\(base)device/\($0)/" }
    }

    static var cookie: HTTPCookie? {
        get {
            let defaults = UserDefaults.standard
            guard let properties = defaults.object(forKey: "kCookie") as? [HTTPCookiePropertyKey : Any] else {
                return nil
            }
            let cookie = HTTPCookie(properties: properties)
            return cookie
        } set(cke) {
            let defaults = UserDefaults.standard
            defaults.set(cke?.properties, forKey: "kCookie")
            defaults.synchronize()
        }
    }

    static var isLogged: Bool {
        guard let cookie = self.cookie
            , let expiration = cookie.expiresDate else {
            return false
        }
        if expiration.timeIntervalSince1970 < Date().timeIntervalSince1970 {
            return false
        } else {
            return true
        }
    }

    class func signup(params: [String: String], fake: Bool = false, completion: @escaping (RequestStatus<User>) -> Void) {

        if fake {
            let usr = User(username: "thiaguera", email: "thiago.martins@gmail.com")
            completion(.success(usr))
            return
        }

        let parameters: Parameters = params
        Alamofire.request(API.user("signup"), method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in

            guard let value = response.result.value else {
                let error = response.result.error!
                completion(.failure(error))
                return
            }

            let json = JSON(value)
            let success = json["success"].boolValue
            if success {
                guard let resp = response.response
                    , let fields = resp.allHeaderFields as? [String : String]
                    , let url = resp.url
                    , let ckie = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url).first else {
                        let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "Não foi possível estabelecer uma sessão com o servidor"]) as Error
                        completion(.failure(error))
                        return
                }
                cookie = ckie
                guard let theUser = User(json: json["user"].json) else {
                    let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "O app está incompatível com as respostas do servidor."]) as Error
                    completion(.failure(error))
                    return
                }
                ServerManager.user = theUser
                completion(.success(theUser))
            } else {
                let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : json["message"].stringValue]) as Error
                completion(.failure(error))
            }
        }
    }

    class func signin(params: [String: String], fake: Bool = false, completion: @escaping (RequestStatus<User>) -> Void) {

        if fake {
            let usr = User(username: "thiaguera", email: "thaigo.martins@gmail.com")
            completion(.success(usr))
            return
        }

        let parameters: Parameters = params
        Alamofire.request(API.user("signin"), method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in

            guard let value = response.result.value else {
                let error = response.result.error!
                completion(.failure(error))
                return
            }

            let json = JSON(value)
            let success = json["success"].boolValue
            if success {
                guard let resp = response.response
                    , let fields = resp.allHeaderFields as? [String : String]
                    , let url = resp.url
                    , let ckie = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url).first else {
                        let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "Não foi possível estabelecer uma sessão com o servidor"]) as Error
                        completion(.failure(error))
                        return
                }
                cookie = ckie
                guard let theUser = User(json: json["user"].json) else {
                    let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "O app está incompatível com as respostas do servidor."]) as Error
                    completion(.failure(error))
                    return
                }
                ServerManager.user = theUser
                completion(.success(theUser))
            } else {
                let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : json["message"].stringValue]) as Error
                completion(.failure(error))
            }
        }
    }

    class func profile(fake: Bool = false, completion: @escaping (RequestStatus<User>) -> Void) {

        if fake {
            completion(.success(ServerManager.user))
            return
        }

        guard let cookie = cookie else {
            let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "Esta sessão foi expirada, faça login novamente"]) as Error
            completion(.failure(error))
            return
        }
        HTTPCookieStorage.shared.setCookie(cookie)

        Alamofire.request(API.user("profile"), method: .get, parameters: nil, encoding: URLEncoding.default).responseJSON { (response) in
            guard let value = response.result.value else {
                let error = response.result.error!
                completion(.failure(error))
                return
            }

            let json = JSON(value)
            let success = json["success"].boolValue
            if success {
                guard let theUser = User(json: json["user"].json) else {
                    let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "O app está incompatível com as respostas do servidor."]) as Error
                    completion(.failure(error))
                    return
                }
                ServerManager.user = theUser
                completion(.success(theUser))
            } else {
                let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : json["message"].stringValue]) as Error
                completion(.failure(error))
            }
        }
    }

    class func forgot(email: String, fake: Bool = false, completion: @escaping (RequestStatus<String>) -> Void) {

        if fake {
            completion(.success("Cheque seu email para modificar sua senha"))
            return
        }

        let parameters: Parameters = ["email" : email]
        Alamofire.request(API.user("forgot"), method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in
            guard let value = response.result.value else {
                let error = response.result.error!
                completion(.failure(error))
                return
            }

            let json = JSON(value)
            let success = json["success"].boolValue
            if success {
                let message = "Pronto!\nPara alterar sua senha, acesse seu e-mail! Enviamos um link para sua conta de e-mail cadastrada que possibilitará a alteração da sua senha."
                completion(.success(message))
            } else {
                let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : json["message"].stringValue]) as Error
                completion(.failure(error))
            }
        }
    }

    class func devices(fake: Bool = false, cached: Bool = true, completion: @escaping (RequestStatus<[Device]>) -> Void) {

        if fake {
            let device = Device(name: "TV da Sala", topic: "tv12345", closed: true, working: true, onDelay: 5, offDelay: 20*60)
            completion(.success([device, device, device, device, device, device]))
            return
        }

        if cached {
            if let devices = ServerManager.cache["devices"] as? [Device] {
                if !devices.isEmpty {
                    completion(.success(devices))
                    return
                }
            }
        }

        guard let cookie = cookie else {
            let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "Esta sessão foi expirada, faça login novamente"]) as Error
            completion(.failure(error))
            return
        }
        HTTPCookieStorage.shared.setCookie(cookie)

        Alamofire.request(API.device("devices"), method: .get, parameters: nil, encoding: URLEncoding.default).responseJSON { (response) in
            guard let value = response.result.value else {
                let error = response.result.error!
                completion(.failure(error))
                return
            }

            let json = JSON(value)
            let devices = json["devices"].json.flatMap({ (jsn) -> Device? in
                return Device(json: jsn)
            })

//            guard let devArray = json["devices"].jsonArray else {
//                let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "Esta sessão foi expirada, faça login novamente"]) as Error
//                completion(.failure(error))
//                return
//            }
//            var devices: [Device] = []
//            for devJsn in devArray {
//                let device = Device(json: devJsn)
//                if device != nil {
//                    devices.append(device!)
//                }
//            }
            ServerManager.cache["devices"] = devices
            completion(.success(devices))
        }
    }

    class func message(topic: String, key:String, value: String, fake: Bool = false, completion: @escaping (RequestStatus<Device>) -> Void) {

        if fake {
            let device = Device(name: "TV da Sala", topic: "tv12345", closed: true, working: true, onDelay: 5, offDelay: 20*60)
            completion(.success(device))
            return
        }

        guard let cookie = cookie else {
            let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "Esta sessão foi expirada, faça login novamente"]) as Error
            completion(.failure(error))
            return
        }
        HTTPCookieStorage.shared.setCookie(cookie)

        Alamofire.request(API.device("update/\(topic)/\(key)/\(value)"), method: .put, parameters: nil, encoding: URLEncoding.default).responseJSON { (response) in
            guard let value = response.result.value else {
                let error = response.result.error!
                completion(.failure(error))
                return
            }

            let json = JSON(value)
            let success = json["success"].boolValue
            if success {
//                let message = json["message"].stringValue
                guard let device = Device(json: json["device"].json) else {
                    let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "O app está incompatível com as respostas do servidor."]) as Error
                    completion(.failure(error))
                    return
                }
                completion(.success(device))
            } else {
                let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : json["message"].stringValue]) as Error
                completion(.failure(error))
            }
        }
    }

    class func delete(topic: String, fake: Bool = false, completion: @escaping (RequestStatus<String>) -> Void) {

        if fake {
            let message = "Dispositivo deletado com sucesso"
            completion(.success(message))
            return
        }

        guard let cookie = cookie else {
            let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "Esta sessão foi expirada, faça login novamente"]) as Error
            completion(.failure(error))
            return
        }
        HTTPCookieStorage.shared.setCookie(cookie)

        let parameters: Parameters = ["topic" : topic]
        Alamofire.request(API.device("delete"), method: .delete, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in
            guard let value = response.result.value else {
                let error = response.result.error!
                completion(.failure(error))
                return
            }

            let json = JSON(value)
            let success = json["success"].boolValue
            if success {
                let message = json["message"].stringValue
                completion(.success(message))
            } else {
                let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : json["message"].stringValue]) as Error
                completion(.failure(error))
            }
        }
    }

    class func add(topic: String, name: String, fake: Bool = false, completion: @escaping (RequestStatus<Device>) -> Void) {

        if fake {
            let device = Device(name: name, topic: topic, closed: true, working: true, onDelay: 5, offDelay: 20*60)
            completion(.success(device))
            return
        }

        guard let cookie = cookie else {
            let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "Esta sessão foi expirada, faça login novamente"]) as Error
            completion(.failure(error))
            return
        }
        HTTPCookieStorage.shared.setCookie(cookie)

        let parameters: Parameters = ["topic" : topic, "name" : name]
        Alamofire.request(API.device("add"), method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in
            guard let value = response.result.value else {
                let error = response.result.error!
                completion(.failure(error))
                return
            }

            let json = JSON(value)
            let success = json["success"].boolValue
            if success {
                guard let device = Device(json: json["device"].json) else {
                    let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "Os dados do dispositivo adicionado não puderam ser lidos. Entre no app novamente para ver se ele foi salvo e, caso não tenha sido, adicione-o novamente"]) as Error
                    completion(.failure(error))
                    return
                }
                if var devices = ServerManager.cache["devices"] as? [Device] {
                    devices.append(device)
                    ServerManager.cache["devices"] = devices
                }
                completion(.success(device))
            } else {
                let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : json["message"].stringValue]) as Error
                completion(.failure(error))
            }
        }
    }

    class func logoff(completion: () -> Void) {

        user = User(username: "default", email: "default@default.com")
        cookie = nil
        self.cache = [:]
        completion()
    }
}
