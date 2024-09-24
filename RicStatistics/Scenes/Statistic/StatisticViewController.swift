
import UIKit
import RxSwift

class StatisticViewController: UIViewController {

    let disposeBag = DisposeBag()

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
        setupBindings()

        Task { [model] in
            await model.loadData()
        }


        PIXEL_PERFECT_screen.createAndSetupInstance(
            baseView: self.view,
            imageName: "PIXEL_PERFECT_main",
            controlsBottomSideOffset: 0,
            imageScaleFactor: 3
        )
    }

}

private extension StatisticViewController {
    // MARK: - Setup

    func setup() {
        customView.addHandlerForRefreshControl(
            target: self,
            #selector(refreshControlValueDidChange(_:))
        )
    }

    func setupBindings() {
        model.topVisitorsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] users in
                //
            })
            .disposed(by: disposeBag)

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

    // MARK: - Actions handlers

    @objc func refreshControlValueDidChange(_ refreshControl: UIRefreshControl) {
        Task { [model] in
            await model.loadData(forceReload: true)
        }
    }

    // MARK: - Helpers
    // TODO: вынести в Presenter?

    func fillVisitorsTrendView(_ visitorsTrend: StatisticTrendModelDto) {
        let trendType = convertTrendModelTypeToViewType(visitorsTrend.trendType)
        let text = buildVisitorsTrendViewTextBy(visitorsTrend.trendType)

        customView.visitorsTrendView.fillVisitorsTrend(
            visitorsCountsByMonths: visitorsTrend.countByPeriod.reversed(),
            count: String(visitorsTrend.delta),
            trendType: trendType,
            text: text
        )
    }

    func fillNewObserversTrendView(_ trend: StatisticTrendModelDto) {
        customView.observersTrendsView.fillNewObserversTrendView(
            countsByMonths: trend.countByPeriod.reversed(),
            count: String(trend.delta)
        )
    }

    func fillLostObserversTrendView(_ trend: StatisticTrendModelDto) {
        customView.observersTrendsView.fillLostObserversTrendView(
            countsByMonths: trend.countByPeriod.reversed(),
            count: String(trend.delta)
        )
    }

    func convertTrendModelTypeToViewType(_ trendType: TrendType) -> StatisticCommonTrendView.TrendType {
        switch trendType {
        case .up:
            return .up
        case .down:
            return .down
        case .flat:
            return .flat
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

}
