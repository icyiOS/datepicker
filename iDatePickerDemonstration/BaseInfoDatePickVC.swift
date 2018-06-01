//
//  BaseInfoDatePickVC.swift
//  iDatePickerDemonstration
//
//  Created by ebuser on 2018/06/01.
//  Copyright © 2018 ebuser. All rights reserved.
//

import RxSwift
import UIKit

final class BaseInfoDatePickVC: UIViewController {
    private let disposeBag = DisposeBag()
    private let datePicker: DatePicker
    private let touchGesture: UILongPressGestureRecognizer
    let currentDate: Variable<Date>

    init(date: Date) {
        datePicker = DatePicker(date: date)
        touchGesture = UILongPressGestureRecognizer()
        currentDate = Variable(date)
        super.init(nibName: nil, bundle: nil)

        touchGesture.minimumPressDuration = 0
        touchGesture.addTarget(self, action: #selector(handleLongGesture(gesture:)))
        touchGesture.cancelsTouchesInView = false
        touchGesture.delegate = self
        view.addGestureRecognizer(touchGesture)

        modalPresentationStyle = .overCurrentContext
        view.backgroundColor = GlobalColor.popUpBackground
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubDatePicker()
    }

    private func addSubDatePicker() {
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        datePicker
            .currentDate
            .asObservable()
            .subscribe(onNext: { [weak self] date in
                self?.currentDate.value = date
            })
            .disposed(by: disposeBag)
    }

    @objc
    private func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            if !datePicker.frame.contains(gesture.location(in: view)) {
                dismiss(animated: false, completion: nil)
            }
        }
    }

}

extension BaseInfoDatePickVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if datePicker.frame.contains(gestureRecognizer.location(in: view)) {
            return false
        } else {
            return true
        }
    }
}
