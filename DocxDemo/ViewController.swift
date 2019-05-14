//
//  ViewController.swift
//  DocxDemo
//
//  Created by RockerHX on 2019/5/9.
//  Copyright © 2019 RockerHX. All rights reserved.
//


import UIKit
import AEXML


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
    }

}

