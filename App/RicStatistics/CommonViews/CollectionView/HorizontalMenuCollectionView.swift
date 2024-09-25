
import UIKit

final class HorizontalMenuCollectionView: UICollectionView {

    // MARK: - Init

    convenience init() {
        self.init(
            frame: .zero,
            collectionViewLayout: Self.buildLayout()
        )
        setup()
    }

}

private extension HorizontalMenuCollectionView {
    // MARK: - Setup

    func setup() {
        register(HorizontalMenuButtonCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalMenuButtonCollectionViewCell.className)

        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        delaysContentTouches = false
    }

    static func buildLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.estimatedItemSize = .init(width: 90, height: 32)

        return layout
    }
}
