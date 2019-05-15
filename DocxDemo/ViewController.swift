//
//  ViewController.swift
//  DocxDemo
//
//  Created by RockerHX on 2019/5/9.
//  Copyright © 2019 RockerHX. All rights reserved.
//


import UIKit
import AEXML
import Zip


class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // 读取xml
        guard let targetURL = Bundle.main.url(forResource: "document", withExtension: "xml") else { return }
        do {
            let data = try Data(contentsOf: targetURL)
            let xmlDoc = try AEXMLDocument(xml: data)
            var body = ""
            xmlDoc.root["w:body"].children.filter{ $0.name == "w:p" }.forEach { (child) in
                let wrs = child.children.filter{ $0["w:t"].value != nil }
                if wrs.isEmpty {
                    body += "\n"
                } else {
                    let content = wrs.compactMap{ $0["w:t"].value }.joined()
                    body += content
                }
            }
            textView?.text = body
        } catch {
            debugPrint(error)
        }

        guard let text = textView?.text else { return }
        let englishParrern = #"[A-Za-z][A-Za-z'\-.]*"#
        let chineseParrern = #"[\u0391-\uFFE5]"#
        do {
            let englishRegex = try NSRegularExpression(pattern: englishParrern, options: [])
            let chineseRegex = try NSRegularExpression(pattern: chineseParrern, options: [])
            let englishMatches = englishRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            print("\(englishMatches.count) matches.")
            let chineseMatches = chineseRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            print("\(chineseMatches.count) matches.")
        } catch {
            print(error.localizedDescription)
        }

//        do {
//            let filePath = Bundle.main.url(forResource: "aaa", withExtension: "zip")!
//            let unzipDirectory = try Zip.quickUnzipFile(filePath) // Unzip
//        }
//        catch {
//            print("Something went wrong")
//        }
    }

}

