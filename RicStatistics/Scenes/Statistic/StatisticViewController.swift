
import UIKit
import RxSwift

class StatisticViewController: UIViewController {

    let disposeBag = DisposeBag()

    // MARK: - Data / State

    private var model: StatisticsModel

    // MARK: - Subviews

    private lazy var customView: StatisticCustomView = .init()

    // MARK: - Init

    init (model: StatisticsModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupBindingsWithModel()
        setupBindingsWithViews()

        Task { [model] in
            await model.loadData(forceReload: true)
        }

//        PIXEL_PERFECT_screen.createAndSetupInstance(
//            baseView: self.view,
//            imageName: "PIXEL_PERFECT_main",
//            controlsBottomSideOffset: 0,
//            imageScaleFactor: 3
//        )
    }

}

private extension StatisticViewController {
    // MARK: - Setup

    func setup() {
        customView.refreshControl.addTarget(
            self,
            action: #selector(refreshControlValueDidChange(_:)),
            for: .valueChanged
        )

        customView.visitorsByPeriodView.setMenuPeriods(VisitorsStatisticPeriod.allCases)
        customView.visitorsByPeriodView.selectMenuItem(with: model.visitorsByPeriodFilter)
    }

    func setupBindingsWithModel() {
        model.isLoadingObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                self?.customView.setIsLoadingRefreshControl(isLoading)
            })
            .disposed(by: disposeBag)


        model.visitorsTrendSubjectObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] visitorsTrend in
                self?.fillVisitorsTrendView(visitorsTrend)
            })
            .disposed(by: disposeBag)

        model.topVisitorsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] users in
                self?.fillTopVisitorsView(users)
            })
            .disposed(by: disposeBag)

        model.visitorsByPeriodsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] visitorsByPeriods in
                self?.fillVisitorsByPeriodsView(visitorsByPeriods)
            })
            .disposed(by: disposeBag)

        model.subscriptionsTrendSubjectObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] trend in
                self?.fillNewObserversTrendView(trend)
            })
            .disposed(by: disposeBag)

        model.unsubscriptionsTrendSubjectObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] trend in
                self?.fillLostObserversTrendView(trend)
            })
            .disposed(by: disposeBag)
    }

    func setupBindingsWithViews() {
        customView.visitorsByPeriodView.disSelectPeriodObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [model] period in
                guard let period else { return }
                model.visitorsByPeriodFilter = period
                model.reloadVisitorsByPeriodsData()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions handlers

    @objc func refreshControlValueDidChange(_ refreshControl: UIRefreshControl) {
        Task { [model] in
            await model.loadData(forceReload: true)
        }
    }

}

private extension StatisticViewController {
    // MARK: - Helpers
    // TODO: вынести часть в сервис подготовки данных / Presenter

    func fillVisitorsTrendView(_ visitorsTrend: VisitorsTrendModelDto) {
        let trendType = convertTrendModelTypeToViewType(visitorsTrend.trendType)
        let text = buildVisitorsTrendViewTextBy(visitorsTrend.trendType)

        customView.visitorsTrendView.fillVisitorsTrend(
            visitorsCountsByMonths: visitorsTrend.countByPeriods,
            count: String(visitorsTrend.countInCurrentMonth),
            trendType: trendType,
            text: text
        )
    }

    // TODO: преобразовать в DTO для view?
    func fillTopVisitorsView(_ users: [TopVisitorModelDto]) {
        customView.topVisitorsProfilesView.reloadTableWithData(users)
    }

    func fillNewObserversTrendView(_ trend: ObserversTrendModelDto) {
        customView.observersTrendsView.fillNewObserversTrendView(
            countsByMonths: trend.countByPeriods,
            count: String(trend.countInCurrentPeriod)
        )
    }

    func fillLostObserversTrendView(_ trend: ObserversTrendModelDto) {
        customView.observersTrendsView.fillLostObserversTrendView(
            countsByMonths: trend.countByPeriods,
            count: String(trend.countInCurrentPeriod)
        )
    }

    func convertTrendModelTypeToViewType(_ trendType: TrendType) -> StatisticLineSimpleTrendChartView.TrendType {
        switch trendType {
        case .up, .flat:
            return .up
        case .down:
            return .down
        }
    }

    func buildVisitorsTrendViewTextBy(_ trendType: TrendType) -> String {
        var text: String
        switch trendType {
        case .up:
            text = "выросло"
        case .down:
            text = "понизилось"
        case .flat:
            text = "не изменилось"
        }

        return "Количество посетителей в этом месяце \(text)"
    }

    func fillVisitorsByPeriodsView(_ visitorsByPeriods: VisitorsByPeriodsModelDto) {
        // TODO: отрефакторить
        var chartData: [StatisticByPeriodLineChart.ChartDataItem] = []
        for visitorsByPeriod in visitorsByPeriods.countByPeriods {
            switch visitorsByPeriods.period {
            case .byDay:
                var labelText = "-"
                var tooltipText = "-"
                if let dayDate = visitorsByPeriod.day {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd.MM"
                    labelText = dateFormatter.string(from: dayDate)

                    dateFormatter.dateFormat = "d MMMM"
                    dateFormatter.locale = .init(identifier: "ru_RU")
                    tooltipText = dateFormatter.string(from: dayDate)
                }

                chartData.append((
                    value: visitorsByPeriod.value,
                    xAxisText: labelText,
                    toolTipText: tooltipText
                ))

            case .byWeek:
                break
            case .byMonth:
                break
            }
        }

        customView.visitorsByPeriodView.setChartDataAndReload(
            data: chartData.reversed(),
            animate: true
        )
    }
}
