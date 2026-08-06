import UIKit

/// The bubbles themselves. Split from the controller so neither file outgrows a read.
extension ConversationViewController: UITableViewDataSource {
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ table: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "bubble", for: path)
        (cell as? BubbleCell)?.show(messages[path.row])

        return cell
    }
}
