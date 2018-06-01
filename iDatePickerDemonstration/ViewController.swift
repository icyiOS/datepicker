//
//  ViewController.swift
//  iDatePickerDemonstration
//
//  Created by ebuser on 2018/06/01.
//  Copyright © 2018 ebuser. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!

    private let disposeBag = DisposeBag()
    private var selectedDate = Variable(Date())

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        selectedDate
            .asObservable()
            .map { $0.dateStringInTokyo }
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func go(_ sender: Any) {
        let datePicker = BaseInfoDatePickVC(date: selectedDate.value)
        datePicker
            .currentDate
            .asObservable()
            .subscribe(onNext: { [weak self] date in
                self?.selectedDate.value = date
            })
            .disposed(by: disposeBag)
        present(datePicker, animated: false, completion: nil)
    }
    
}

