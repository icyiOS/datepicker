//
//  DatePicker.swift
//  iDatePickerDemonstration
//
//  Created by ebuser on 2018/06/01.
//  Copyright © 2018 ebuser. All rights reserved.
//

import RxSwift
import UIKit

final class DatePicker: UIView {

    let disposeBag = DisposeBag()
    // 通知上层(BaseInfoDatePickVC)
    let currentDate: Variable<Date>
    // 通知下层(pageViewController的子节点)
    let currentDateComponents: Variable<DateComponents>

    private let yearLabel: UILabel
    private let pageViewController: UIPageViewController
    private let weekdayStack: UIStackView
    private let nextButton: UIButton
    private let prevButton: UIButton

    private let calendar = Calendar.current

    init(date: Date) {
        currentDate = Variable(date)
        currentDateComponents = Variable(calendar.dateComponents([.year, .month, .day], from: date))
        yearLabel = UILabel()
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal)
        weekdayStack = UIStackView()
        nextButton = UIButton(type: .custom)
        prevButton = UIButton(type: .custom)
        super.init(frame: .zero)

        backgroundColor = BaseInfoColor.baseInfoViewBackground

        addSubYearLabel()
        addSubPageViewController()
        addSubWeekdayStack()
        addSubNextButtons()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 342)
    }

    private func addSubYearLabel() {
        addSubview(yearLabel)
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        yearLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        yearLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        yearLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        yearLabel.textAlignment = .center
        yearLabel.textColor = BaseInfoColor.baseInfoPickerGray
        yearLabel.font = UIFont.boldSystemFont(ofSize: 16)

        if let year = currentDateComponents.value.year {
            yearLabel.text = "\(year)"
        }
    }

    private func addSubPageViewController() {
        addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        pageViewController.view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: yearLabel.bottomAnchor).isActive = true
        pageViewController.delegate = self
        pageViewController.dataSource = self

        let currentMonthComponents = calendar.dateComponents([.year, .month], from: currentDate.value)
        let thisMonthCalendarController = MonthCalendarController(dateComponents: currentMonthComponents, delegate: self)
        pageViewController.setViewControllers([thisMonthCalendarController], direction: .forward, animated: false)
    }

    private func addSubWeekdayStack() {
        weekdayStack.axis = .horizontal
        weekdayStack.alignment = .fill
        weekdayStack.distribution = .fillEqually
        var weekdayLabels = [UILabel]()

        let dateFormatter = DateFormatter()
        for i in 0..<7 {
            let label = UILabel()
            label.textAlignment = .center
            label.text = dateFormatter.veryShortStandaloneWeekdaySymbols[i]
            label.font = UIFont.systemFont(ofSize: 12)
            switch i {
            case 0, 6:
                label.textColor = BaseInfoColor.baseInfoPickerGray
            default:
                label.textColor = BaseInfoColor.baseInfoPickerBlack
            }
            weekdayLabels.append(label)
        }
        for label in weekdayLabels {
            weekdayStack.addArrangedSubview(label)
        }
        addSubview(weekdayStack)
        weekdayStack.translatesAutoresizingMaskIntoConstraints = false
        weekdayStack.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        weekdayStack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        weekdayStack.topAnchor.constraint(equalTo: topAnchor, constant: 90).isActive = true
        weekdayStack.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }

    private func addSubNextButtons() {
        nextButton.tintColor = BaseInfoColor.baseInfoPickerBlack
        nextButton.setImage(#imageLiteral(resourceName: "date_picker_arrow_right"), for: .normal)
        addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        nextButton.centerYAnchor.constraint(equalTo: topAnchor, constant: 70).isActive = true
        nextButton.addTarget(self, action: #selector(nextButtonPressed(_:)), for: .touchUpInside)

        prevButton.tintColor = BaseInfoColor.baseInfoPickerBlack
        prevButton.setImage(#imageLiteral(resourceName: "date_picker_arrow_left"), for: .normal)
        addSubview(prevButton)
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        prevButton.centerYAnchor.constraint(equalTo: topAnchor, constant: 70).isActive = true
        prevButton.addTarget(self, action: #selector(prevButtonPressed(_:)), for: .touchUpInside)
    }

    private func updateYearLabel(for dateComponents: DateComponents) {
        guard let year = dateComponents.year else {
            return
        }
        yearLabel.text = "\(year)"
    }

    fileprivate func updateSelected(components: DateComponents) {
        if let date = calendar.date(from: components) {
            currentDate.value = date
            currentDateComponents.value = components
        }
    }

    @objc
    private func nextButtonPressed(_ sender: UIButton) {
        guard let currentVC = pageViewController.viewControllers?.first else {
            return
        }

        guard let nextVC = pageViewController.dataSource?.pageViewController(pageViewController, viewControllerAfter: currentVC) as? MonthCalendarController else {
            return
        }

        pageViewController.setViewControllers([nextVC], direction: .forward, animated: true) { [weak self] _ in
            self?.updateYearLabel(for: nextVC.dateComponents)
        }
    }

    @objc
    private func prevButtonPressed(_ sender: UIButton) {
        guard let currentVC = pageViewController.viewControllers?.first else {
            return
        }

        guard let prevVC = pageViewController.dataSource?.pageViewController(pageViewController, viewControllerBefore: currentVC) as? MonthCalendarController else {
            return
        }

        pageViewController.setViewControllers([prevVC], direction: .reverse, animated: true) { [weak self] _ in
            self?.updateYearLabel(for: prevVC.dateComponents)
        }
    }

}

extension DatePicker: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? MonthCalendarController else {
            return nil
        }
        guard let thisMonthDate = calendar.date(from: viewController.dateComponents) else {
            return nil
        }
        guard let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: thisMonthDate) else {
            return nil
        }
        let lastMonthComponents = calendar.dateComponents([.year, .month], from: lastMonthDate)
        let lastMonthCalendarController = MonthCalendarController(dateComponents: lastMonthComponents, delegate: self)
        return lastMonthCalendarController
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? MonthCalendarController else {
            return nil
        }
        guard let thisMonthDate = calendar.date(from: viewController.dateComponents) else {
            return nil
        }
        guard let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: thisMonthDate) else {
            return nil
        }
        let nextMonthComponents = calendar.dateComponents([.year, .month], from: nextMonthDate)
        let nextMonthCalendarController = MonthCalendarController(dateComponents: nextMonthComponents, delegate: self)
        return nextMonthCalendarController
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let dateComponents = (pageViewController.viewControllers?.first as? MonthCalendarController)?.dateComponents else {
            return
        }
        updateYearLabel(for: dateComponents)
    }
}

private final class MonthCalendarController: UIViewController {

    private let disposeBag = DisposeBag()

    let dateComponents: DateComponents

    let selectedDaySubject = PublishSubject<DateComponents?>()

    private let monthLabel: UILabel

    private let collectionView: UICollectionView
    private let cellIdentifier = "cellIdentifier"

    private let firstWeekDayInMonth: Int
    private let numberOfDaysInMonth: Int

    private var emphasizedIndex: IndexPath?

    //swiftlint:disable:next function_body_length
    init(dateComponents: DateComponents, delegate: DatePicker) {
        self.dateComponents = dateComponents
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)
        numberOfDaysInMonth = date?.numberOfDaysInMonth() ?? 0
        firstWeekDayInMonth = date?.firstWeekdayInMonth() ?? 0

        monthLabel = UILabel()

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = BaseInfoColor.baseInfoViewBackground
        addSubMonthLabel()
        addSubBorder()
        addSubCollectionView()
        // 通知上层用户选择了日期
        selectedDaySubject
            .subscribe(onNext: { dateComponents in
                if let dateComponents = dateComponents {
                    delegate.updateSelected(components: dateComponents)
                }
            })
            .disposed(by: delegate.disposeBag)
        // 接受上层通知：用户选择日期变化
        delegate
            .currentDateComponents
            .asObservable()
            .subscribe(onNext: { [weak self] dateComponents in
                guard let strongSelf = self else { return }
                guard let year = dateComponents.year,
                    let month = dateComponents.month,
                    let day = dateComponents.day else {
                        return
                }
                if let indexPath = strongSelf.emphasizedIndex {
                    strongSelf.emphasizedIndex = nil
                    let cell = strongSelf.collectionView.cellForItem(at: indexPath) as? MonthCalendarCell
                    cell?.unEmphasize()
                }
                guard let thisYear = strongSelf.dateComponents.year,
                    let thisMonth = strongSelf.dateComponents.month,
                    thisYear == year && thisMonth == month else {
                        return
                }
                let indexPath = IndexPath(item: strongSelf.firstWeekDayInMonth + day - 1, section: 0)
                strongSelf.emphasizedIndex = indexPath
                let cell = strongSelf.collectionView.cellForItem(at: indexPath) as? MonthCalendarCell
                cell?.emphasize()
            })
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubMonthLabel() {
        view.addSubview(monthLabel)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        monthLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        monthLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        monthLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        monthLabel.font = UIFont.boldSystemFont(ofSize: 16)
        monthLabel.textAlignment = .center
        monthLabel.backgroundColor = UIColor.white

        guard let month = dateComponents.month else {
            return
        }
        let dateFormatter = DateFormatter()
        let monthName = dateFormatter.shortMonthSymbols[month - 1]
        monthLabel.text = monthName
    }

    private func addSubBorder() {
        let topBorder = UIView()
        let bottomBorder = UIView()
        view.addSubview(topBorder)
        view.addSubview(bottomBorder)
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        topBorder.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topBorder.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topBorder.topAnchor.constraint(equalTo: monthLabel.topAnchor).isActive = true
        topBorder.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        bottomBorder.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomBorder.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomBorder.bottomAnchor.constraint(equalTo: monthLabel.bottomAnchor).isActive = true
        bottomBorder.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        topBorder.backgroundColor = GlobalColor.seperatorGray
        bottomBorder.backgroundColor = GlobalColor.seperatorGray
    }

    private func addSubCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 216).isActive = true

        collectionView.register(MonthCalendarCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.backgroundColor = BaseInfoColor.baseInfoViewBackground
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension MonthCalendarController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? MonthCalendarCell else {
            fatalError("Unknown cell type")
        }
        switch indexPath.item % 7 {
        case 0, 6:
            cell.dayType = .weekend
        default:
            cell.dayType = .weekday
        }
        if indexPath.item >= firstWeekDayInMonth && indexPath.item < firstWeekDayInMonth + numberOfDaysInMonth {
            cell.day = indexPath.item - firstWeekDayInMonth + 1
            if let emphasizedIndex = emphasizedIndex, emphasizedIndex == indexPath {
                cell.emphasize()
            } else {
                cell.unEmphasize()
            }
        } else {
            cell.day = nil
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  CGSize(width: UIScreen.main.bounds.width / 7, height: 36)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if indexPath.item >= firstWeekDayInMonth && indexPath.item < firstWeekDayInMonth + numberOfDaysInMonth {
            var selectedDayComponents = dateComponents
            selectedDayComponents.day = indexPath.item - firstWeekDayInMonth + 1
            selectedDaySubject.onNext(selectedDayComponents)
        }
    }
}

private final class MonthCalendarCell: UICollectionViewCell {

    var dayType = DayType.weekday {
        didSet {
            switch dayType {
            case .weekday:
                dayLabel.textColor = BaseInfoColor.baseInfoPickerBlack
            case .weekend:
                dayLabel.textColor = BaseInfoColor.baseInfoPickerGray
            }
        }
    }

    var day: Int? {
        didSet {
            if let day = day {
                dayLabel.text = "\(day)"
            } else {
                dayLabel.text = nil
            }
        }
    }
    private let dayLabel: UILabel
    private var circle: UIView

    override init(frame: CGRect) {
        dayLabel = UILabel()
        circle = UIView()
        super.init(frame: frame)

        addSubCircile()
        addSubDayLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubCircile() {
        circle.backgroundColor = UIColor.red
        circle.layer.cornerRadius = 18
        circle.layer.masksToBounds = true
        addSubview(circle)
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 36).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 36).isActive = true
        circle.isHidden = true
    }

    private func addSubDayLabel() {
        addSubview(dayLabel)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        dayLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        dayLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dayLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        dayLabel.textAlignment = .center
        dayLabel.font = UIFont.boldSystemFont(ofSize: 16)
    }

    func emphasize() {
        dayLabel.textColor = UIColor.white
        circle.isHidden = false
    }

    func unEmphasize() {
        switch dayType {
        case .weekday:
            dayLabel.textColor = BaseInfoColor.baseInfoPickerBlack
        case .weekend:
            dayLabel.textColor = BaseInfoColor.baseInfoPickerGray
        }
        circle.isHidden = true
    }

    enum DayType {
        case weekday
        case weekend
    }
}
