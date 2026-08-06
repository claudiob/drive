import UIKit

/// The rows and the two section headers.
extension JobsViewController {
    static func titled(_ text: String) -> NSAttributedString {
        let font = UIFont.preferredFont(forTextStyle: .title2)
        let title = NSMutableAttributedString(
            string: text + " ",
            attributes: [.font: UIFont.systemFont(ofSize: font.pointSize, weight: .bold)]
        )

        let chevron = NSTextAttachment()
        chevron.image = UIImage(
            systemName: "chevron.forward",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: font.pointSize * 0.7,
                                                           weight: .bold)
        )?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
        title.append(NSAttributedString(attachment: chevron))

        return title
    }

    override func numberOfSections(in view: UICollectionView) -> Int {
        jobs.count
    }

    override func collectionView(_ view: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        jobs[section].count
    }

    override func collectionView(_ view: UICollectionView,
                                 cellForItemAt path: IndexPath) -> UICollectionViewCell {
        view.dequeueConfiguredReusableCell(using: cell, for: path,
                                           item: jobs[path.section][path.item])
    }

    override func collectionView(
        _ view: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at path: IndexPath
    ) -> UICollectionReusableView {
        view.dequeueConfiguredReusableSupplementary(using: header, for: path)
    }

    override func collectionView(_ view: UICollectionView, didSelectItemAt path: IndexPath) {
        view.deselectItem(at: path, animated: true)

        route(jobs[path.section][path.item].path)
    }
}
