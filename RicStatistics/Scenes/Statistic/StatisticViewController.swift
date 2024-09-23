
import UIKit

class StatisticViewController: UIViewController {

    // MARK: - Subviews

    private lazy var customView: StatisticCustomView = .init()

    // MARK: - Lifecycle

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()

        PIXEL_PERFECT_screen.createAndSetupInstance(
            baseView: self.view,
            imageName: "PIXEL_PERFECT_main",
            controlsBottomSideOffset: 0,
            imageScaleFactor: 3
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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

    // MARK: - Actions handlers

    @objc func refreshControlValueDidChange(_ refreshControl: UIRefreshControl) {
        Task {
            print("Запросить данные из API")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            refreshControl.endRefreshing()
            print("Данные получены")
        }

    }
}
