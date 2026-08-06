import UIKit

/// The bubbles themselves. Split from the controller so neither file outgrows a read.
extension ConversationViewController: UITableViewDataSource {
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ table: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        switch rows[path.row] {
        case let .time(caption):
            let cell = table.dequeueReusableCell(withIdentifier: "time", for: path)
            (cell as? TimeCell)?.show(caption)

            return cell
        case let .bubble(message, reports):
            let cell = table.dequeueReusableCell(withIdentifier: "bubble", for: path)
            (cell as? BubbleCell)?.show(message, reports: reports)

            return cell
        }
    }
}
