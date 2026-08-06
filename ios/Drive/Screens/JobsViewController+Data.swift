import UIKit

/// The rows and the two section headers. The registrations are built here but held by
/// the controller, because one made lazily inside the callback that dequeues it is
/// something UIKit aborts on.
extension JobsViewController {
    /// `subtitleCell`, not `valueCell`: the title always leads and the location always
    /// sits under it, muted. `valueCell` lifts the detail up beside a short title and
    /// only drops it below a long one, so rows of mixed lengths never line up.
    static func makeCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, Job> {
        UICollectionView.CellRegistration { cell, _, job in
            var content = UIListContentConfiguration.subtitleCell()
            content.text = job.title
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.secondaryText = job.city
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
            content.secondaryTextProperties.color = .secondaryLabel
            content.textToSecondaryTextVerticalPadding = 3

            // A reserved slot, so the hammer beside a short title and the one beside a
            // long title start in the same place; and room above and below, which is
            // what makes two lines read as one row rather than two.
            content.image = UIImage(
                systemName: "hammer.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 19)
            )
            content.imageProperties.reservedLayoutSize = CGSize(width: 32, height: 32)
            content.imageToTextPadding = 14
            content.directionalLayoutMargins = .init(top: 12, leading: 4, bottom: 12, trailing: 0)

            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }
    }

    /// The extra-prominent header is the large bold one the App Store uses over each of
    /// its groups; the chevron rides in the text so it follows the words rather than
    /// sitting out at the trailing edge.
    static func makeHeader()
        -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        UICollectionView.SupplementaryRegistration(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { view, _, path in
            var content = UIListContentConfiguration.extraProminentInsetGroupedHeader()
            content.attributedText = titled(JobsViewController.groups[path.section])
            view.contentConfiguration = content
        }
    }

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
