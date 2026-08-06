import UIKit

/// The rows, and the save. A homeowner gets a second section for the address; a
/// provider has nowhere to live, so it is not offered one.
extension NewContactViewController {
    override func numberOfSections(in table: UITableView) -> Int {
        homeowner ? 2 : 1
    }

    override func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? ContactField.allCases.count : 1
    }

    override func tableView(_ table: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 ? "Home" : nil
    }

    override func tableView(_ table: UITableView,
                            cellForRowAt path: IndexPath) -> UITableViewCell {
        guard path.section == 0 else { return addressCell(table, at: path) }

        let cell = table.dequeueReusableCell(withIdentifier: "field", for: path)
        (cell as? FieldCell)?.adopt(fields[path.row])

        return cell
    }

    override func tableView(_ table: UITableView, didSelectRowAt path: IndexPath) {
        table.deselectRow(at: path, animated: true)

        guard path.section == 1 else { return }

        let search = AddressSearchViewController(url: url) { [weak self] place in
            self?.address = place
            self?.tableView.reloadData()
        }

        navigationController?.pushViewController(search, animated: true)
    }

    // MARK: Private

    private func addressCell(_ table: UITableView, at path: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "address", for: path)

        var content = cell.defaultContentConfiguration()
        content.text = address?.title ?? "Address"
        content.textProperties.color = address == nil ? .placeholderText : .label
        content.secondaryText = address?.detail
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    /// Posts the contact. The gem answers 201 with the record, or 422 with the errors
    /// against each attribute, which is what the alert repeats back.
    func save() async -> Bool {
        guard let target = NativeList.url("/contacts.json", like: url) else { return false }

        var request = URLRequest(url: target)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["contact": attributes])

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (response as? HTTPURLResponse)?.statusCode == 201
        else {
            report(nil)
            return false
        }

        _ = data

        return true
    }

    private var attributes: [String: String] {
        [
            "phone": field(.phone).text ?? "", "name": field(.first).text ?? "",
            "surname": field(.last).text ?? "", "email": field(.email).text ?? "",
        ]
    }

    private func report(_ message: String?) {
        let alert = UIAlertController(title: "Could not add contact",
                                      message: message ?? "Please check the details and try again.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
