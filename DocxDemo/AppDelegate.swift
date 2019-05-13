//
//  AppDelegate.swift
//  DocxDemo
//
//  Created by RockerHX on 2019/5/9.
//  Copyright © 2019 RockerHX. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

}


extension String {

    func delete(prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    func delete(suffix: String) -> String {
        guard self.contains(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }

    func delete(prefix: String, suffix: String) -> String {
        let tmp = self.delete(prefix: prefix)
        return tmp.delete(suffix: suffix)
    }

}


import Files
import Zip
import AEXML

extension AppDelegate {

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let fileAgreement = "file://"
        let docSuffix = ".docx"
        let zipSuffix = ".zip"
        if url.absoluteString.contains(fileAgreement) {
            var fileURL = url
            let fileNameSuffix = fileURL.lastPathComponent
            let fileName = fileNameSuffix.delete(suffix: docSuffix)
            // 使用Folder库初始化的路径不能带协议，不能带文件名
            fileURL.deleteLastPathComponent()
            let filePath = fileURL.absoluteString.delete(prefix: fileAgreement)
            do {
                // 先清空临时文件夹
                try Folder.temporary.files.forEach { (file) in
                    try file.delete()
                }
                try Folder.temporary.subfolders.forEach { (folder) in
                    try folder.delete()
                }
                // 操作临时文件
                let fileFolder = try Folder(path: filePath)
                let file = try fileFolder.file(named: fileNameSuffix)
                let tmpFile = try file.copy(to: Folder.temporary)
                try tmpFile.rename(to: fileName + zipSuffix, keepExtension: false)
                // 初始化解压路径
                guard let utf8 = "\(fileAgreement)\(tmpFile.path)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                      let source = URL(string: utf8),
                      let target = URL(string: fileAgreement + Folder.temporary.path)
                else { return false}
                // 解压操作
                try Zip.unzipFile(source, destination: target, overwrite: true, password: nil, progress: { (progress) -> () in
                    print(progress)
                })
                // 读取xml
                let targetFile = try Folder.temporary.subfolder(named: "word").file(named: "document.xml")
                guard let targetURL = URL(string: fileAgreement + targetFile.path) else { return false }
                let data = try Data(contentsOf: targetURL)
                let xmlDoc = try AEXMLDocument(xml: data)
                debugPrint(xmlDoc.xml)
            } catch {
                debugPrint(error)
            }
        }
        return true
    }

}

